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

None (buckets and KMS key ARN referenced directly by the [sql_executor](../sql_executor/README.md) workspace via data sources).
