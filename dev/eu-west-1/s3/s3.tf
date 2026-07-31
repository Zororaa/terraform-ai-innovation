module "s3_storage" {
  source      = "git::https://github.com/atl-ai-innovation/terraform-modules.git//s3?ref=v0.9.1"
  bucket_name = local.bucket_name

  #force_destroy       = false
  #versioning_enabled  = true
  #object_ownership    = BucketOwnerEnforced
  #block_public_access = true

  #enable_server_side_encryption = true
  #sse_algorithm                 = AES256

  tags = local.tags
}

