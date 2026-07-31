provider "aws" {
  region = var.aws_region
}

locals {
  tags = {
    "Owner" : "ai-innovation",
    "Environment" : var.env
    "Repository" : "terraform-ai-innovation-genai",
    "CostCenter" : "genai"
  }

  # Read certificate files from the certificates directory
  certificate_body  = file("${path.module}/../../../certificates/star_apollotyres_com.crt")
  certificate_chain = file("${path.module}/../../../certificates/bundle.crt")
}

# Import certificate to AWS Certificate Manager (ACM) for ALB use
resource "aws_acm_certificate" "apollotyres_wildcard" {
  private_key       = var.atl_domain_tls_cert_pk
  certificate_body  = local.certificate_body
  certificate_chain = local.certificate_chain

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

# Store certificate ARN in SSM for other workspaces to consume
resource "aws_ssm_parameter" "certificate_arn" {
  name        = "/shared/certificates/apollotyres_wildcard_arn"
  description = "ARN of the *.apollotyres.com ACM certificate"
  type        = "String"
  value       = aws_acm_certificate.apollotyres_wildcard.arn

  tags = local.tags
}
