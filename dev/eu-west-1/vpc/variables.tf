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
