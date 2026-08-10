output "db_instance_endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = module.rds_instance.db_instance_endpoint
}

output "db_instance_identifier" {
  description = "The RDS instance identifier"
  value       = module.rds_instance.db_instance_identifier
}

output "security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.vpc_rds_sg.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for RDS secret encryption"
  value       = aws_kms_key.rds_secret.arn
}


################################################################################
# Database Connection Outputs
################################################################################

output "db_instance_username" {
  description = "Master username for the RDS instance"
  value       = var.db_admin_name
}

output "db_instance_password" {
  description = "Master password for the RDS instance"
  value       = random_password.atlas_db_password.result
  sensitive   = true
}

output "db_instance_hostname" {
  description = "Hostname of the RDS instance"
  value       = module.rds_instance.db_instance_address
}

output "db_instance_port" {
  description = "Port of the RDS instance"
  value       = module.rds_instance.db_instance_port
}


output "db_instance_name" {
  description = "RDS initial database name"
  value       = var.database_name
}

