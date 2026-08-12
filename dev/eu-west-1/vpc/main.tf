provider "aws" {
  region = var.aws_region
}

data "aws_organizations_organization" "current" {}

data "aws_caller_identity" "current" {}

locals {
  management_account_id = data.aws_organizations_organization.current.master_account_id

  tags = {
    Owner       = "ai-innovation"
    Environment = var.env
    Repository  = "terraform-ai-innovation-genai"
    CostCenter  = "genai"
  }

  current_account_name   = "ai-innovation-genai-${var.env}"
  workload_vpc_param_key = "arn:aws:ssm:${var.aws_region}:${local.management_account_id}:parameter/shared-networking-config/spoke_vpcs/${local.current_account_name}/workload_vpc"
  gateway_vpc_param_key  = "arn:aws:ssm:${var.aws_region}:${local.management_account_id}:parameter/shared-networking-config/spoke_vpcs/${local.current_account_name}/gateway_vpc"

  flow_logs_expiration_days = 90
}

data "aws_ssm_parameter" "workload_vpc_networking_params" {
  name = local.workload_vpc_param_key
}

data "aws_ssm_parameter" "gateway_vpc_networking_params" {
  name = local.gateway_vpc_param_key
}

locals {
  shared_networking_params  = jsondecode(data.aws_ssm_parameter.workload_vpc_networking_params.insecure_value)
  gateway_networking_params = jsondecode(data.aws_ssm_parameter.gateway_vpc_networking_params.insecure_value)
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

################################################## Write Gateway VPC ID to SSM ##########################################
resource "aws_ssm_parameter" "gateway_vpc_id" {
  name           = "/network/gateway_vpc_id"
  type           = "String"
  insecure_value = module.gateway_vpc.vpc_id
}

################################# Write Gateway VPC private subnet IDs to SSM ###########################################
resource "aws_ssm_parameter" "gateway_vpc_private_subnet_ids" {
  name           = "/network/gateway_vpc_private_subnet_ids"
  type           = "StringList"
  insecure_value = join(",", module.gateway_vpc.private_subnets)
}

################################# Write Gateway VPC CIDR Block to SSM ################################################
resource "aws_ssm_parameter" "gateway_vpc_cidr_block" {
  name           = "/network/gateway_vpc_cidr_block"
  type           = "String"
  insecure_value = module.gateway_vpc.vpc_cidr_block
}
