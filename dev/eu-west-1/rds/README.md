# RDS (Atlas PostgreSQL)

Provisions a PostgreSQL RDS instance for the Atlas application, encrypted at rest with a dedicated KMS key.

## Resources

- **RDS Instance** — PostgreSQL 16 on `db.t4g.medium`, single-AZ in dev
- **KMS Key** — Dedicated key for RDS storage encryption (auto-rotation enabled)
- **Security Group** — Allows inbound PostgreSQL (5432) from VPC CIDR
- **DB Subnet Group** — Private subnets only

## Configuration

| Setting | Value |
|---------|-------|
| Engine | PostgreSQL 16 |
| Instance class | db.t4g.medium (Graviton) |
| Encryption | KMS at rest, TLS in transit (`rds.force_ssl = 1`) |
| Extensions | pgvector (vector similarity search) |
| Logging | DDL statements, connections, lock waits → CloudWatch |
| Autovacuum | Tuned (naptime 60s, custom thresholds) |

## SSM Parameters

### Consumed

| Parameter | Source | Description |
|-----------|--------|-------------|
| `/network/vpc_id` | [vpc](../vpc/README.md) | VPC for security group and subnet group |
| `/network/vpc_cidr_block` | [vpc](../vpc/README.md) | VPC CIDR for security group ingress |
| `/network/private_subnet_ids` | [vpc](../vpc/README.md) | Subnets for DB subnet group |

### Produced

| Parameter | Description |
|-----------|-------------|
| `/internal/atlas_rds/db_username` | Master username |
| `/internal/atlas_rds/db_password` | Master password (SecureString) |
| `/internal/atlas_rds/db_hostname` | RDS endpoint hostname |
| `/internal/atlas_rds/db_port` | RDS port |
| `/internal/atlas_rds/db_instance_name` | Database name |
| `/internal/atlas_rds/database_url` | FastAPI async database URL (SecureString) |

These parameters are consumed by: [sql_executor](../sql_executor/README.md).
