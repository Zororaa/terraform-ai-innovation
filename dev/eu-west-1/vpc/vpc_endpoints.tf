######################################## VPC Endpoints ###################################################
resource "aws_security_group" "vpc_endpoints_sg" {
  vpc_id      = module.workload_vpc.vpc_id
  name        = "${local.workload_vpc_name}-endpoints-sg"
  description = "Allows 443 (HTTPS) inbound from VPC subnets to Interface Endpoints"

  ingress {
    description = "Allow HTTPS from the private subnets CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.workload_vpc.vpc_cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({ Name = "${local.workload_vpc_name}-endpoints-sg" }, local.tags)
}

data "aws_iam_policy_document" "default_interface_endpoint_policy" {
  statement {
    sid    = "AllowOnlyCurrentAccount"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["*"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.current.id
      ]
    }
  }
}

data "aws_iam_policy_document" "api_gateway_endpoint_policy" {
  statement {
    sid    = "AllowOnlyCurrentAccount"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "s3_interface_endpoint_policy" {
  statement {
    sid    = "AllowOnlyCurrentAccount"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["*"]
    resources = ["*"]
  }
}


module "vpc-endpoints" {
  source             = "git::https://github.com/atl-ai-innovation/terraform-modules.git//vpc-endpoints?ref=v0.7.2"
  vpc_id             = module.workload_vpc.vpc_id
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
  subnet_ids         = module.workload_vpc.private_subnets
  enabled_gateway_endpoints = [
    {
      gateway_name    = "s3"
      gateway_policy  = data.aws_iam_policy_document.s3_interface_endpoint_policy.json
      route_table_ids = module.workload_vpc.private_route_table_ids
    },
    {
      gateway_name    = "dynamodb"
      gateway_policy  = data.aws_iam_policy_document.default_interface_endpoint_policy.json
      route_table_ids = module.workload_vpc.private_route_table_ids
    },
  ]

  enabled_interface_endpoints = [
    { endpoint_name : "codeartifact.api", endpoint_policy : data.aws_iam_policy_document.default_interface_endpoint_policy.json },
    { endpoint_name : "codeartifact.repositories", endpoint_policy : data.aws_iam_policy_document.default_interface_endpoint_policy.json },
    { endpoint_name : "ecr.dkr", endpoint_policy : data.aws_iam_policy_document.default_interface_endpoint_policy.json },
    { endpoint_name : "ecr.api", endpoint_policy : data.aws_iam_policy_document.default_interface_endpoint_policy.json },
    { endpoint_name : "logs", endpoint_policy : data.aws_iam_policy_document.default_interface_endpoint_policy.json },
    { endpoint_name : "sagemaker.api", endpoint_policy : data.aws_iam_policy_document.default_interface_endpoint_policy.json },
    { endpoint_name : "sagemaker.runtime", endpoint_policy : data.aws_iam_policy_document.default_interface_endpoint_policy.json },
    { endpoint_name : "execute-api", endpoint_policy : data.aws_iam_policy_document.api_gateway_endpoint_policy.json },
    { endpoint_name : "ssm", endpoint_policy : data.aws_iam_policy_document.default_interface_endpoint_policy.json },
    { endpoint_name : "ssmmessages", endpoint_policy : data.aws_iam_policy_document.default_interface_endpoint_policy.json },
    { endpoint_name : "ec2messages", endpoint_policy : data.aws_iam_policy_document.default_interface_endpoint_policy.json },
  ]
  tags = local.tags
}
