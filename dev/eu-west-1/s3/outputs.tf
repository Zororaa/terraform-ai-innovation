output "project_name_parameter" {
  description = "Containing the project name"
  value       = aws_ssm_parameter.project_name.name
}

output "environment_parameter" {
  description = "Containing the environment"
  value       = aws_ssm_parameter.environment.name
}

output "region_shortcode_parameter" {
  description = "Containing the AWS Region short code"
  value       = aws_ssm_parameter.region_shortcode.name
}

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.s3_storage.bucket_id

}

output "project_name" {
  description = "Project name retrieved from SSM Parameter Store"
  value       = local.project_name
}


output "region_shortcode" {
  description = "Region short code retrieved from SSM Parameter Store"
  value       = local.aws_region_shortcode
}