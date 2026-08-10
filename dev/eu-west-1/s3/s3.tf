module "s3_storage" {
  source      = "git::https://github.com/atl-ai-innovation/terraform-modules.git//s3?ref=v0.10.2"
  bucket_name = local.bucket_name
  kms_key_arn = aws_kms_key.s3.arn

  tags = local.tags
}

module "s3_ddl_storage" {
  source      = "git::https://github.com/atl-ai-innovation/terraform-modules.git//s3?ref=v0.10.2"
  bucket_name = local.bucket_name_rds
  kms_key_arn = aws_kms_key.s3.arn

  tags = local.tags
}


data "archive_file" "sql_scripts" {
  type        = "zip"
  source_dir  = "${path.module}/../../../sql/${var.env}"
  output_path = "${path.module}/files/sql_scripts.zip"
}

resource "aws_s3_object" "sql_scripts" {
  bucket = module.s3_ddl_storage.bucket_id
  key    = "sql/${var.env}/sql_scripts.zip"
  source = data.archive_file.sql_scripts.output_path
  etag   = data.archive_file.sql_scripts.output_md5

  tags = local.tags
}

