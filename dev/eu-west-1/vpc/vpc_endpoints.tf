######################################### VPC Endpoints ###################################################
resource "aws_security_group" "vpc_endpoints_sg" {
  vpc_id      = module.workload_vpc.vpc_id
  name        = "${local.workload_vpc_name}-endpoints-sg"
  description = "Allows 443 (HTTPS) inbound from VPC subnets to Interface Endpoints"

  # == INGRESS (Inbound) RULES ==
  # Interface Endpoints only need to accept connections on port 443 (HTTPS).
  # The source of the traffic should be your application subnets/resources (e.g., your VPC's private CIDR).
  ingress {
    description = "Allow HTTPS from the private subnets CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Only allow the main CIDR block for incoming traffic.
    cidr_blocks = [module.workload_vpc.vpc_cidr_block]
  }

  # == EGRESS (Outbound) RULES ==
  # Interface Endpoints typically don't need any special outbound rules,
  # but it's best practice to explicitly control outbound traffic.
  # Allowing all outbound traffic (0.0.0.0/0) is the default for AWS but is defined here for clarity.
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
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
