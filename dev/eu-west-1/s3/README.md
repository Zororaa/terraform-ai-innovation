# S3

Provisions encrypted S3 buckets for the GenAI workload account.

## Resources

- **General S3 Bucket** — KMS-encrypted storage for application data
- **DDL S3 Bucket** — Stores SQL script archives for RDS schema initialization
- **KMS Key** — Dedicated encryption key shared by both buckets

## Buckets

| Bucket | Purpose |
|--------|---------|
| `{project}-{env}-{region}-{account_id}` | General application storage |
| `{project}-{env}-{region}-ddl-{account_id}` | SQL DDL scripts archive |

## SQL Script Archival

SQL files from `sql/{env}/` are automatically zipped and uploaded to the DDL bucket on each apply. The [sql_executor](../sql_executor/README.md) workspace fetches these archives to run against RDS.

## SSM Parameters

### Consumed

None.

### Produced

This Terraform project creates the following AWS Systems Manager Parameter
Store parameters. These values allow downstream infrastructure, such as the ECS
application project, to reference the application data bucket and its KMS key.

| Parameter name | Description | Type |
|---|---|---|
| `/internal/data/bucket_name` | Name of the S3 bucket used to store application data | `local.bucket_name` |
| `/internal/data/bucket_arn` | `String` | ARN of the S3 bucket used to store application data | `module.s3_storage.bucket_arn` |
| `/internal/data/kms_key_arn` | ARN of the KMS key used to encrypt the application data bucket | `aws_kms_key.s3.arn` |

These parameters are consumed by: [shared_ecs](../shared_ecs/README.md).
