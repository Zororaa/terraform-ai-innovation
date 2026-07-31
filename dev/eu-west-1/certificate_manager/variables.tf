variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "The AWS Region to deploy resources to."
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment (dev|prod)"
}

variable "atl_domain_tls_cert_pk" {
  type        = string
  sensitive   = true
  description = "Private key for *.apollotyres.com certificate (injected via TF_VAR_ from GitHub secret)"
}
