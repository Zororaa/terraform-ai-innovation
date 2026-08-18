# terraform-ai-innovation-genai

Terraform repository for the AI Innovation GenAI workload accounts (`ai-innovation-genai-dev`, `ai-innovation-genai-prod`). Manages networking, compute, storage, and application infrastructure.

## Workspaces

| Service | Path | Description |
|---------|------|-------------|
| [vpc](./dev/eu-west-1/vpc/README.md) | dev/eu-west-1/vpc | Workload + Gateway VPCs, TGW attachments, VPC endpoints, flow logs |
| [certificate_manager](./dev/eu-west-1/certificate_manager/README.md) | dev/eu-west-1/certificate_manager | `*.apollotyres.com` wildcard TLS certificate in ACM |
| [shared_ecs](./dev/eu-west-1/shared_ecs/README.md) | dev/eu-west-1/shared_ecs | Shared ECS Fargate cluster |
| [shared_alb](./dev/eu-west-1/shared_alb/README.md) | dev/eu-west-1/shared_alb | Internal ALB, HTTPS listener, Route 53 private hosted zone |
| [rds](./dev/eu-west-1/rds/README.md) | dev/eu-west-1/rds | Atlas PostgreSQL RDS with KMS encryption and pgvector |
| [s3](./dev/eu-west-1/s3/README.md) | dev/eu-west-1/s3 | S3 buckets with KMS encryption, SQL DDL archive |
| [sql_executor](./dev/eu-west-1/sql_executor/README.md) | dev/eu-west-1/sql_executor | PostgreSQL DDL executor (ECS task) |
| [secure-browser](./dev/eu-west-1/secure-browser/README.md) | dev/eu-west-1/secure-browser | AWS WorkSpaces Secure Browser portal |

## Related Repositories

- [aws-org-management](https://github.com/atl-ai-innovation/aws-org-management) — VPC/subnet CIDR definitions, RAM-shared SSM parameters consumed by the VPC workspace
- [terraform-ai-innovation-shared-services](https://github.com/atl-ai-innovation/terraform-ai-innovation-shared-services) — Hub VPCs, Transit Gateways, VPN gateways, ECR repositories
- [terraform-modules](https://github.com/atl-ai-innovation/terraform-modules) — Reusable Terraform modules

## Architecture

```
On-Prem ──── VPN ──── TGW (shared-services) ──── Spoke VPCs (this account)
                                                    ├── Workload VPC (ECS, RDS, S3)
                                                    └── Gateway VPC (ALB, Route 53)
```

Both VPCs are private-only (no public subnets, no NAT gateways). All internet access routes via the Transit Gateway to hub NAT gateways in the shared-services account.

## SSM Parameters

All SSM parameters produced and consumed are documented in their respective workspace READMEs:

- [VPC parameters](./dev/eu-west-1/vpc/README.md#ssm-parameters)
- [Shared ECS parameters](./dev/eu-west-1/shared_ecs/README.md#ssm-parameters)
- [Shared ALB parameters](./dev/eu-west-1/shared_alb/README.md#ssm-parameters)
- [RDS parameters](./dev/eu-west-1/rds/README.md#ssm-parameters)
- [Certificate parameters](./dev/eu-west-1/certificate_manager/README.md#ssm-parameters)

## Conventions

- Directory structure: `<env>/<region>/<workspace>/`
- Each workspace has independent Terraform state in S3
- Tags: Owner, Environment, Repository, CostCenter
- Cross-workspace communication via SSM Parameter Store
- Secrets injected via GitHub Actions secrets, never hardcoded
- Modules sourced from `atl-ai-innovation/terraform-modules` or local `modules/`

## CI/CD

Each workflow in `.github/workflows/` detects changed workspaces and runs:

| Trigger | Action |
|---------|--------|
| PR to `main` | `terraform plan` posted as PR comment |
| Merge to `main` | `terraform apply` |

Workspaces run sequentially (`max-parallel: 1`) to avoid state conflicts.
