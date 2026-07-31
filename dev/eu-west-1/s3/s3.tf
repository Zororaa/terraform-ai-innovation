module "s3_storage" {
  source      = "git::https://github.com/atl-ai-innovation/terraform-modules.git//s3?ref=v0.10.2"
  bucket_name = local.bucket_name
  kms_key_arn = aws_kms_key.s3.arn

  tags = local.tags
}

