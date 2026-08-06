provider "aws" {
  region = var.aws_region
}

data "aws_organizations_organization" "current" {}

locals {
  management_account_id = data.aws_organizations_organization.current.master_account_id

  tags = {
    "Owner" : "ai-innovation",
    "Environment" : var.env
    "Repository" : "terraform-ai-innovation-genai",
    "CostCenter" : "genai",
    "Team" : "apexon",
  }

  current_account_name = "ai-innovation-genai-${var.env}"

  project_name         = lower(var.project_name)
  environment          = lower(var.env)
  aws_region_shortcode = lower(var.aws_region_shortcode)

  active_name = "${local.project_name}-${local.environment}-${local.aws_region_shortcode}"

  rds_private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.insecure_value)

}

################################################################################
# Data sources
################################################################################

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/network/private_subnet_ids"
}

data "aws_ssm_parameter" "vpc_cidr_block" {
  name = "/network/vpc_cidr_block"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/network/vpc_id"
}


################################################################################
# Database Connection SSM Parameters
################################################################################

resource "aws_ssm_parameter" "db_username" {
  name           = "/internal/atlas_rds/db_username"
  type           = "String"
  insecure_value = module.atlas_rds.db_instance_username

  tags = local.tags
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/internal/atlas_rds/db_password"
  type  = "SecureString"
  value = module.atlas_rds.db_instance_password

  tags = local.tags
}

resource "aws_ssm_parameter" "db_hostname" {
  name           = "/internal/atlas_rds/db_hostname"
  type           = "String"
  insecure_value = module.atlas_rds.db_instance_hostname

  tags = local.tags
}

resource "aws_ssm_parameter" "db_port" {
  name           = "/internal/atlas_rds/db_port"
  type           = "String"
  insecure_value = tostring(module.atlas_rds.db_instance_port)

  tags = local.tags
}

################################################################################
# RDS Module
################################################################################

module "atlas_rds" {
  source = "../../../modules/atlas_rds"

  active_name  = local.active_name
  project_name = local.project_name
  environment  = local.environment
  aws_region   = var.aws_region

  vpc_id             = data.aws_ssm_parameter.vpc_id.insecure_value
  vpc_cidr_block     = data.aws_ssm_parameter.vpc_cidr_block.insecure_value
  private_subnet_ids = local.rds_private_subnet_ids

  db_admin_name = "postgres_admin"

  db_parameters = [
    # Logging
    {
      name         = "log_statement"
      value        = "ddl"
      apply_method = "immediate"
    },
    {
      name         = "log_min_duration_statement"
      value        = "1000"
      apply_method = "immediate"
    },
    {
      name         = "log_connections"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "log_disconnections"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "log_lock_waits"
      value        = "1"
      apply_method = "immediate"
    },

    # Security
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "immediate"
    },

    # Autovacuum
    {
      name         = "autovacuum"
      value        = "on"
      apply_method = "immediate"
    },
    {
      name         = "autovacuum_naptime"
      value        = "60"
      apply_method = "immediate"
    },
    {
      name         = "autovacuum_vacuum_threshold"
      value        = "50"
      apply_method = "immediate"
    },
    {
      name         = "autovacuum_max_workers"
      value        = "2"
      apply_method = "pending-reboot"
    },
    {
      name         = "autovacuum_vacuum_scale_factor"
      value        = "0.2"
      apply_method = "immediate"
    },
    {
      name         = "autovacuum_analyze_threshold"
      value        = "50"
      apply_method = "immediate"
    },
    {
      name         = "autovacuum_analyze_scale_factor"
      value        = "0.1"
      apply_method = "immediate"
    },
    {
      name         = "autovacuum_vacuum_cost_delay"
      value        = "20"
      apply_method = "immediate"
    },
    {
      name         = "autovacuum_vacuum_cost_limit"
      value        = "2000"
      apply_method = "immediate"
    },
    {
      name         = "rds.extensions"
      value        = "pgvector"
      apply_method = "pending-reboot" # Static parameters require a reboot
    }
  ]

  tags = local.tags
}

