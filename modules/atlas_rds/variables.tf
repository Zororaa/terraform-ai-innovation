variable "active_name" {
  type        = string
  description = "Naming prefix for all resources (e.g. atlas-dev-euw1)"
}

variable "project_name" {
  type        = string
  description = "Project name used in tags and KMS alias"
}

variable "environment" {
  type        = string
  description = "Environment name (dev|prod)"
}

variable "aws_region" {
  type        = string
  description = "AWS region for availability zone selection"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the RDS instance will be deployed"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block for security group ingress"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the DB subnet group"
}

variable "db_admin_name" {
  type        = string
  description = "PostgreSQL administrative username"
  default     = "postgres_admin"
}

variable "db_port" {
  type        = number
  description = "database port for postgres"
  default     = 5432
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t4g.medium"
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version"
  default     = "16"
}

variable "allocated_storage" {
  type        = number
  description = "Initial allocated storage in GB"
  default     = 50
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum allocated storage in GB for autoscaling"
  default     = 200
}

variable "deletion_window_in_days" {
  type        = number
  description = "deletion window in days"
  default     = 30
}

variable "enable_key_rotation" {
  type        = bool
  description = "enable rotation keys"
  default     = true
}

variable "multi_region" {
  type        = bool
  description = "multi region template"
  default     = false
}


variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
}


variable "enabled_cloudwatch_logs_exports" {
  description = "PostgreSQL log types exported to CloudWatch Logs."
  type        = list(string)

  default = [
    "postgresql",
    "upgrade"
  ]
}

variable "create_cloudwatch_log_group" {
  description = "Whether Terraform should create the RDS CloudWatch log groups."
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_class" {
  description = "CloudWatch Logs class used for the RDS log groups."
  type        = string
  default     = "STANDARD"

}

variable "cloudwatch_log_group_skip_destroy" {
  description = "Whether CloudWatch log groups should remain after the RDS deployment is destroyed."
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days RDS logs are retained in CloudWatch."
  type        = number
  default     = 30
}

variable "db_parameters" {
  description = "PostgreSQL DB parameter group settings supplied by the calling environment."

  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))

}

