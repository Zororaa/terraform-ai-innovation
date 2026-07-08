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
    "CostCenter" : "shared"
  }

  current_account_name = "ai-innovation-genai-${var.env}"
  networking_param_key = "arn:aws:ssm:${var.aws_region}:${local.management_account_id}:parameter/shared-networking-config/spoke_vpcs/${local.current_account_name}"
}

data "aws_ssm_parameter" "ssm_networking_params" {
  name = local.networking_param_key
}

locals {
  shared_networking_params = jsondecode(data.aws_ssm_parameter.ssm_networking_params.insecure_value)
}

################################################## Write VPC ID to SSM #################################################
resource "aws_ssm_parameter" "vpc_id" {
  name           = "/network/vpc_id"
  type           = "String"
  insecure_value = module.workload_vpc.vpc_id
}

################################# Write private subnet IDs to SSM as a comma-separated string ##########################
resource "aws_ssm_parameter" "private_subnet_ids" {
  name           = "/network/private_subnet_ids"
  type           = "StringList"
  insecure_value = join(",", module.workload_vpc.private_subnets)
}

################################# Write VPC CIDR Block ##########################
resource "aws_ssm_parameter" "vpc_cidr_block" {
  name           = "/network/vpc_cidr_block"
  type           = "String"
  insecure_value = module.workload_vpc.vpc_cidr_block
}

############################## Workload VPC with connection to Shared TGW #########################################
data "aws_ec2_transit_gateway" "shared_tgw" {
  filter {
    name   = "options.amazon-side-asn"
    values = [local.shared_networking_params.asn]
  }
}

resource "aws_ssm_service_setting" "block_public_ssm_documents" {
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"
}
