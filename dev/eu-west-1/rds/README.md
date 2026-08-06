# RDS (Atlas PostgreSQL)

This workspace provisions a PostgreSQL RDS instance for the Atlas application in `eu-west-1`.

## Resources

- **RDS Instance** — PostgreSQL 16 on `db.t4g.medium`, encrypted at rest via KMS, single-AZ in dev
- **KMS Key** — Dedicated key for RDS storage encryption
- **Security Group** — Allows inbound PostgreSQL (5432) from VPC CIDR
- **DB Subnet Group** — Private subnets only

## SSM Parameters

| Parameter | Description |
|-----------|-------------|
| `/internal/atlas_rds/db_username` | Master username |
| `/internal/atlas_rds/db_password` | Master password (SecureString) |
| `/internal/atlas_rds/db_hostname` | RDS instance hostname |
| `/internal/atlas_rds/db_port` | RDS instance port |

## SSM Dependencies

| Parameter | Description |
|-----------|-------------|
| `/network/vpc_id` | VPC ID (read) |
| `/network/vpc_cidr_block` | VPC CIDR block (read) |
| `/network/private_subnet_ids` | Private subnet IDs (read) |

## Notable Configuration

- `rds.force_ssl = 1` — enforces TLS connections
- `rds.extensions = pgvector` — enables vector similarity search
- Autovacuum tuned for moderate workloads
- CloudWatch log exports: `postgresql`, `upgrade`
