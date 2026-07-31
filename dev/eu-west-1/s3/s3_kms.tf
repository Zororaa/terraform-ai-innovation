data "aws_iam_policy_document" "kms_s3" {
  statement {
    sid    = "EnableAccountPermissions"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_kms_key" "s3" {
  description = "KMS key used to encrypt the ${local.project_name} ${local.environment} S3 bucket"

  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = false

  policy = data.aws_iam_policy_document.kms_s3.json

  tags = merge(
    local.tags,
    {
      Name    = "${local.project_name}-${local.environment}-s3-kms"
      Service = "s3"
      Purpose = "S3 bucket encryption"
    }
  )
}

resource "aws_kms_alias" "s3" {
  name = join("/", [
    "alias",
    "${local.project_name}-${local.environment}-s3"
  ])

  target_key_id = aws_kms_key.s3.key_id
}
