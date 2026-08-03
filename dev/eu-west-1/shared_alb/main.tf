provider "aws" {
  region = var.aws_region
}

# =============================================================
# Workload VPC SSM Parameters
# =============================================================
data "aws_ssm_parameter" "workload_vpc_id" {
  name = "/network/vpc_id"
}

data "aws_ssm_parameter" "workload_vpc_cidr_block" {
  name = "/network/vpc_cidr_block"
}

# =============================================================
# Gateway VPC SSM Parameters
# =============================================================
data "aws_ssm_parameter" "gateway_vpc_id" {
  name = "/network/gateway_vpc_id"
}

data "aws_ssm_parameter" "gateway_private_subnets" {
  name = "/network/gateway_vpc_private_subnet_ids"
}

data "aws_ssm_parameter" "gateway_vpc_cidr_block" {
  name = "/network/gateway_vpc_cidr_block"
}

data "aws_ssm_parameter" "apollo_wildcard_certificate" {
  name = "/shared/certificates/apollotyres_wildcard_arn"
}

locals {
  tags = {
    "Owner" : "ai-innovation",
    "Environment" : var.env
    "Repository" : "terraform-ai-innovation-genai",
    "CostCenter" : "genai"
  }
  shared_alb_name         = "shared-alb-${var.env}"
  shared_alb_idle_timeout = 60
  private_subnet_ids      = split(",", data.aws_ssm_parameter.gateway_private_subnets.value)
}

resource "aws_lb" "shared_alb" {
  name               = local.shared_alb_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.shared_alb_sg.id]
  subnets            = local.private_subnet_ids

  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = local.shared_alb_idle_timeout

  tags = merge(
    local.tags,
    {
      Name = local.shared_alb_name
    }
  )
}

# HTTPS Listener with fixed response
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.shared_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_ssm_parameter.apollo_wildcard_certificate.value

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }

  tags = local.tags
}

#---------------------------------------------------
#                 Private Hosted Zone
#---------------------------------------------------
resource "aws_route53_zone" "private" {
  name = "apollotyres.com"
  vpc {
    vpc_id = data.aws_ssm_parameter.gateway_vpc_id.value
  }
  tags = local.tags
}

resource "aws_route53_zone_association" "workload_vpc_hosted_zone_assoc" {
  zone_id = aws_route53_zone.private.zone_id
  vpc_id  = data.aws_ssm_parameter.workload_vpc_id.value
}
