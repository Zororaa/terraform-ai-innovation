
# --------------------------
# workload VPC without Public Subnets
# --------------------------

locals {
  workload_vpc_name         = local.shared_networking_params.vpc_name
  private_subnets           = local.shared_networking_params.private_subnets
  workload_vpc_cidr         = local.shared_networking_params.vpc_cidr
  vpc_flow_logs_bucket_name = "vpc-flow-logs-genai-${var.env}-${var.aws_region}-${data.aws_caller_identity.current.account_id}"
}

data "aws_iam_policy_document" "flow_logs_bucket_policy" {
  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.vpc_flow_logs_bucket_name}/AWSLogs/aws-account-id=${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }

  statement {
    sid    = "AWSLogDeliveryAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.vpc_flow_logs_bucket_name}"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

module "workload_vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "6.5.0"
  name                 = local.workload_vpc_name
  cidr                 = local.workload_vpc_cidr
  azs                  = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets      = local.private_subnets
  enable_nat_gateway   = false
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = local.tags
}

moved {
  from = module.workload_vpc_flow_logs_bucket
  to   = module.vpc_flow_logs_bucket
}
module "vpc_flow_logs_bucket" {
  source            = "git::https://github.com/atl-ai-innovation/terraform-modules.git//s3?ref=v0.10.2"
  bucket_name       = local.vpc_flow_logs_bucket_name
  bucket_policy     = data.aws_iam_policy_document.flow_logs_bucket_policy.json
  enable_versioning = false
  prefix_lifecycle_rules = {
    "AWSLogs/" = {
      expiration_days = local.flow_logs_expiration_days
    }
  }
  tags = local.tags
}

# --------------------------
# workload VPC flow-logs
# --------------------------
module "workload_vpc_flow_logs" {
  source               = "terraform-aws-modules/vpc/aws//modules/flow-log"
  version              = "6.5.0"
  name                 = "${local.workload_vpc_name}-flow-logs"
  vpc_id               = module.workload_vpc.vpc_id
  tags                 = local.tags
  flow_log_tags        = local.tags
  log_destination_type = "s3"
  log_destination      = module.vpc_flow_logs_bucket.bucket_arn
  destination_options = {
    file_format                = "parquet"
    hive_compatible_partitions = true
    per_hour_partition         = true
  }
  max_aggregation_interval = 600
}

# --------------------------
# Transit Gateway Attachment - Spoke VPC
# --------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "workload_vpc_attachment" {
  subnet_ids                                      = module.workload_vpc.private_subnets
  transit_gateway_id                              = data.aws_ec2_transit_gateway.shared_tgw.id
  vpc_id                                          = module.workload_vpc.vpc_id
  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = merge(local.tags, {
    Name = "${local.workload_vpc_name}-tgw-attachment"
  })
}

# --------------------------
# Route spoke internet traffic through hub NAT Gateways
# --------------------------
resource "aws_route" "spoke_private_to_tgw" {
  count                  = length(module.workload_vpc.private_route_table_ids)
  route_table_id         = module.workload_vpc.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway.shared_tgw.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.workload_vpc_attachment]
}

# --------------------------
# Gateway VPC without Public Subnets
# --------------------------

locals {
  gateway_vpc_name = local.gateway_networking_params.vpc_name
  gateway_subnets  = local.gateway_networking_params.private_subnets
  gateway_vpc_cidr = local.gateway_networking_params.vpc_cidr
}

module "gateway_vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "6.5.0"
  name                 = local.gateway_vpc_name
  cidr                 = local.gateway_vpc_cidr
  azs                  = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets      = local.gateway_subnets
  enable_nat_gateway   = false
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = local.tags
}

# --------------------------
# Gateway VPC flow-logs
# --------------------------
module "gateway_vpc_flow_logs" {
  source               = "terraform-aws-modules/vpc/aws//modules/flow-log"
  version              = "6.5.0"
  name                 = "${local.gateway_vpc_name}-flow-logs"
  vpc_id               = module.gateway_vpc.vpc_id
  tags                 = local.tags
  flow_log_tags        = local.tags
  log_destination_type = "s3"
  log_destination      = module.vpc_flow_logs_bucket.bucket_arn
  destination_options = {
    file_format                = "parquet"
    hive_compatible_partitions = true
    per_hour_partition         = true
  }
  max_aggregation_interval = 600
}

# --------------------------
# Transit Gateway Attachment - Gateway VPC
# --------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "gateway_vpc_attachment" {
  subnet_ids                                      = module.gateway_vpc.private_subnets
  transit_gateway_id                              = data.aws_ec2_transit_gateway.shared_tgw.id
  vpc_id                                          = module.gateway_vpc.vpc_id
  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = merge(local.tags, {
    Name = "${local.gateway_vpc_name}-tgw-attachment"
  })
}

# --------------------------
# Route gateway VPC traffic through TGW
# --------------------------
resource "aws_route" "gateway_private_to_tgw" {
  count                  = length(module.gateway_vpc.private_route_table_ids)
  route_table_id         = module.gateway_vpc.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway.shared_tgw.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.gateway_vpc_attachment]
}
