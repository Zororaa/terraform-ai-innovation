################################################################################
# AWS identity data sources
################################################################################

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

################################################################################
# Locals
################################################################################

locals {
  project_name         = lower(var.project_name)
  environment          = lower(var.env)
  aws_region_shortcode = lower(var.aws_region_shortcode)

  tags = {
    "Owner" : "ai-innovation",
    "Environment" : var.env
    "Repository" : "terraform-ai-innovation-genai",
    "CostCenter" : "genai",
    "Team" : "apexon",
  }

  active_name      = "${local.project_name}-${local.environment}-${local.aws_region_shortcode}"
  bucket_name_rds  = "${local.active_name}-ddl-${data.aws_caller_identity.current.account_id}"
  kms_key_s3_alias = "alias/${local.project_name}-${local.environment}-s3"
  ddl_object_key   = "sql/${local.environment}/sql_scripts.zip"
}


################################################################################
# Existing S3 configuration
# NOTE: These resources are defined in the dev/eu-west-1/s3 workspace
################################################################################

data "aws_s3_bucket" "ddl" {
  bucket = local.bucket_name_rds
}

data "aws_kms_key" "atlas_s3_kms_key" {
  key_id = local.kms_key_s3_alias # Use KMS alias to lookup key
}

################################################################################
# Network parameters
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
# Existing database parameters
################################################################################

data "aws_ssm_parameter" "db_instance_name" {
  name = "/internal/atlas_rds/db_instance_name"
}

data "aws_ssm_parameter" "db_username" {
  name = "/internal/atlas_rds/db_username"
}

data "aws_ssm_parameter" "db_port" {
  name = "/internal/atlas_rds/db_port"
}

data "aws_ssm_parameter" "db_hostname" {
  name = "/internal/atlas_rds/db_hostname"
}

data "aws_ssm_parameter" "db_password" {
  name            = "/internal/atlas_rds/db_password"
  with_decryption = true
}

################################################################################
# RDS PostgreSQL executor
################################################################################

module "postgres_executor" {
  source = "git::https://github.com/atl-ai-innovation/terraform-modules.git//postgres-executor?ref=v0.11.1"

  name       = "${local.active_name}-postgres-executor"
  vpc_id     = data.aws_ssm_parameter.vpc_id.value
  aws_region = var.aws_region

  image = "101636218814.dkr.ecr.eu-west-1.amazonaws.com/postgres_executor:0.2.0"

  s3_uri         = "s3://${local.bucket_name_rds}/${local.ddl_object_key}"
  s3_bucket_arn  = data.aws_s3_bucket.ddl.arn
  s3_kms_key_arn = data.aws_kms_key.atlas_s3_kms_key.arn

  database_name = data.aws_ssm_parameter.db_instance_name.value

  db_secret_arns = {
    host     = data.aws_ssm_parameter.db_hostname.arn
    port     = data.aws_ssm_parameter.db_port.arn
    dbname   = data.aws_ssm_parameter.db_instance_name.arn
    username = data.aws_ssm_parameter.db_username.arn
    password = data.aws_ssm_parameter.db_password.arn
  }

  tags = local.tags
}
