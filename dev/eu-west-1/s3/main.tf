provider "aws" {
  region = var.aws_region
}

data "aws_organizations_organization" "current" {}

data "aws_caller_identity" "current" {}

locals {
  management_account_id = data.aws_organizations_organization.current.master_account_id

  tags = {
    "Owner" : "ai-innovation",
    "Environment" : var.env
    "Repository" : "terraform-ai-innovation-genai",
    "CostCenter" : "shared",
    "Team" : "shared",
  }

  current_account_name = "ai-innovation-internal-${var.env}"
  parameter_prefix     = "/${var.project_name}/${var.env}/shared"

  project_name         = lower(nonsensitive(aws_ssm_parameter.project_name.value))
  environment          = lower(nonsensitive(aws_ssm_parameter.environment.value))
  aws_region_shortcode = lower(nonsensitive(aws_ssm_parameter.region_shortcode.value))

  active_name = join("-", [
    local.project_name,
    local.environment,
    local.aws_region_shortcode
  ])

  bucket_name = lower(
    join("-", [
      local.active_name,
      data.aws_caller_identity.current.account_id
    ])
  )

}


#################################################### s3 contents to ssm ######################################################

resource "aws_ssm_parameter" "project_name" {
  name        = "${local.parameter_prefix}/project-name"
  description = "Project name used by Atlas Terraform projects"
  type        = "String"
  value       = var.project_name

  tags = {
    Name = "${var.project_name}-${var.env}-project-name"
  }
}


resource "aws_ssm_parameter" "environment" {
  name        = "${local.parameter_prefix}/environment"
  description = "Environment used by Atlas Terraform projects"
  type        = "String"
  value       = var.env

  tags = {
    Name = "${var.project_name}-${var.env}-environment"
  }
}

resource "aws_ssm_parameter" "region_shortcode" {
  name        = "${local.parameter_prefix}/region-shortcode"
  description = "AWS Region short code used in resource names"
  type        = "String"
  value       = var.aws_region_shortcode

  tags = {
    Name = "${var.project_name}-${var.env}-region-shortcode"
  }
}