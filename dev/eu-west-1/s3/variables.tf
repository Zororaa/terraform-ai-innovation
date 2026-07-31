variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "The AWS Region to deploy resources to."
}

variable "aws_region_shortcode" {
  type        = string
  default     = "euw1"
  description = "The AWS Region to deploy resources to."
}

variable "project_name" {
  type        = string
  default     = "atlas"
  description = "Name of project"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment (dev|prod)"
}



variable "tags" {
  description = "Default tags applied to resources"
  type        = map(string)
  default     = {}
}
