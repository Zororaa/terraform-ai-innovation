variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region for availability zone selection"
}

variable "aws_region_shortcode" {
  type        = string
  default     = "euw1"
  description = "The AWS Region to deploy resources to."
}


variable "project_name" {
  type        = string
  default     = "atlas"
  description = "Project name used in tags and KMS alias"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment (dev|prod)"
}
