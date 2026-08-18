# SQL Executor

Deploys a PostgreSQL executor task that runs DDL scripts against the Atlas RDS instance.

## How It Works

1. SQL scripts are versioned in `sql/{env}/` and archived to S3 by the [s3](../s3/README.md) workspace
2. This workspace provisions an ECS task (via the `postgres_executor` module) that:
   - Fetches the SQL archive from S3
   - Connects to the Atlas RDS instance
   - Executes the DDL scripts

## Resources

- **postgres_executor module** — ECS task definition and execution role
  - Image: `postgres_executor` from shared ECR
  - Deployed in workload VPC private subnets

## SSM Parameters

### Consumed

| Parameter | Source | Description |
|-----------|--------|-------------|
| `/network/vpc_id` | [vpc](../vpc/README.md) | VPC for task placement |
| `/network/vpc_cidr_block` | [vpc](../vpc/README.md) | VPC CIDR for security group |
| `/network/private_subnet_ids` | [vpc](../vpc/README.md) | Subnets for task placement |
| `/internal/atlas_rds/db_instance_name` | [rds](../rds/README.md) | Database name |
| `/internal/atlas_rds/db_username` | [rds](../rds/README.md) | Database username |
| `/internal/atlas_rds/db_password` | [rds](../rds/README.md) | Database password (SecureString) |
| `/internal/atlas_rds/db_hostname` | [rds](../rds/README.md) | RDS endpoint |
| `/internal/atlas_rds/db_port` | [rds](../rds/README.md) | RDS port |

### Produced

None.
