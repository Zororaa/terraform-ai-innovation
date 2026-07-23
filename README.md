# terraform-ai-innovation-genai

This repository contains the Terraform configuration for managing and deploying cloud infrastructure across development
and production environments in AWS for the `ai-innovation-genai-dev` and `ai-innovation-genai-prod` accounts.

## Architecture & Deployment Model

This repository uses a structured deployment model where **each environment (e.g., `dev`, `prod`) and each AWS region
has its own dedicated Terraform pipeline**. The `.github/workflows` directory contains one GitHub Actions workflow
per environment+region combination for managing the Terraform resources under `<env>/<region>/<workspace>`.

Workspaces are isolated — each subdirectory under `<env>/<region>/` is an independent Terraform root module with its
own state file. Only workspaces that changed in a pull request or push will be planned/applied.

## Directory Structure

```
.
├── dev/
│   └── eu-west-1/
│       └── vpc/              # Each directory here is a workspace
├── prod/
│   └── eu-west-1/
│       └── <workspace>/
├── modules/                  # Reusable Terraform modules (if needed)
└── .github/
    └── workflows/            # One workflow per environment+region
        └── terraform-dev-eu-west-1.yaml
```

## Workspaces

Each workspace is an independent Terraform root module. A workspace always contains the following files:

| File | Purpose |
|------|---------|
| `main.tf` | Provider configuration, locals, and primary resource definitions |
| `variables.tf` | Input variables with defaults |
| `versions.tf` | Terraform and provider version constraints |
| `backend.tf` | S3 backend configuration pointing to the workspace's state file |
| `outputs.tf` | Output values (optional, when other workspaces need to reference data) |

### State Management

Each workspace stores its state in S3 following the pattern:

```
s3://ai-innovation-terraform-state-<account-id>/<env>/<region>/<workspace>/terraform.tfstate
```

State locking is handled via S3 native lock files (`use_lockfile = true`).

### Cross-Workspace Communication

Workspaces are isolated and cannot directly reference each other's resources. To share data between workspaces
(e.g., VPC ID, subnet IDs, ALB DNS names), use **AWS SSM Parameter Store**. Write outputs to a well-known parameter
path (e.g., `/network/vpc_id`) and read them via `aws_ssm_parameter` data sources in dependent workspaces.

## CI/CD Pipeline

Each workflow (e.g., `.github/workflows/terraform-dev-eu-west-1.yaml`) contains two jobs:

### detect-changes

This job determines which Terraform workspaces have changed by inspecting the directory structure.
It outputs a list of changed directories, e.g.:

```json
["dev/eu-west-1/vpc", "dev/eu-west-1/ecs"]
```

### terraform

The terraform job:

- Runs one workspace at a time (`max-parallel: 1`) to avoid state conflicts
- Delegates execution to a centralized shared Terraform workflow at `atl-ai-innovation/shared-workflows`
- Passes environment, region, and workspace directory explicitly
- Uses AWS IAM roles for read-only (plan) and read-write (apply) Terraform actions

### PR vs Merge Behaviour

| Trigger | Action |
|---------|--------|
| Pull request to `main` | `terraform plan` — results posted as a PR comment |
| Push/merge to `main` | `terraform apply` — infrastructure is deployed |

Only workspaces with file changes in the triggering event are processed.

## Terraform Rules

### Version Constraints

- Terraform `>= 1.1`
- AWS provider `~> 6.11`

### Required Tags

All resources must include the following tags:

```hcl
locals {
  tags = {
    "Owner"       : "ai-innovation"
    "Environment" : var.env
    "Repository"  : "terraform-ai-innovation-genai"
    "CostCenter"  : "shared"
  }
}
```

### Variable Conventions

- No `.tfvars` files — variables use sensible defaults or are set via CI environment
- Environment (`dev`/`prod`) and region are always parameterized via variables
- Secrets are passed through GitHub Actions secrets, never hardcoded

### Backend Configuration

Every workspace must define an S3 backend with:

```hcl
terraform {
  backend "s3" {
    bucket       = "ai-innovation-terraform-state-<account-id>"
    key          = "<env>/<region>/<workspace>/terraform.tfstate"
    region       = "<region>"
    use_lockfile = true
    encrypt      = false
  }
}
```

### Module Usage

- Reusable modules live in the `modules/` directory within this repo
- External shared modules are sourced from the `atl-ai-innovation/terraform-modules` GitHub repository
- Keep modules generic; pass environment-specific configuration via variables

### Adding a New Workspace

1. Create a new directory under `<env>/<region>/<workspace>/`
2. Add the standard files: `main.tf`, `variables.tf`, `versions.tf`, `backend.tf`
3. Configure the S3 backend key to match the directory path
4. Include the required tags in `locals`
5. The CI pipeline will automatically detect and deploy changes on the next PR/merge

### Adding a New Environment or Region

1. Create the directory structure: `<env>/<region>/`
2. Add a new GitHub Actions workflow: `.github/workflows/terraform-<env>-<region>.yaml`
3. Configure the workflow to watch the correct path and use the appropriate IAM roles for the target account

## DEV Workspaces

### eu-west-1

- [vpc](./dev/eu-west-1/vpc) — Private workload VPC with Transit Gateway connectivity, VPC flow logs, and VPC endpoints

#### VPC Workspace

The VPC workspace provisions the core networking layer:
- Workload VPC — Private-only VPC (no public subnets, no NAT gateway). Hosts application workloads: ECS tasks, RDS instances, ElastiCache, etc. CIDR and subnet configuration are read from the management account's SSM Parameter Store (`/shared-networking-config/spoke_vpcs/workload_vpc/ai-innovation-genai-<env>`).
- Gateway VPC — Private-only VPC (no public subnets, no NAT gateway). Hosts only the shared Application Load Balancer, ALB listeners, and Route 53 private hosted zone (apollotyres.com). This separation satisfies company-specific network segmentation requirements. CIDR and subnet configuration are read from the management account's SSM Parameter Store (`/shared-networking-config/spoke_vpcs/gateway_vpc/ai-innovation-genai-<env>`).
- **Transit Gateway Attachment** — Connects the spoke VPC to the shared Transit Gateway for internet access via hub NAT gateways. All private route tables route `0.0.0.0/0` through the TGW.
- **VPC Flow Logs** — Exported to S3 in Parquet format with Hive-compatible partitions, per-hour granularity, and 90-day retention.
- **VPC Endpoints** — Gateway endpoints for S3 and DynamoDB; interface endpoints for CodeArtifact, ECR, CloudWatch Logs, SageMaker, API Gateway, and Systems Manager. All scoped to the AWS Organization.

#### Gateway VPC vs Workload VPC
This repository will contain both a **Workload VPC** and **Gateway VPC**. The gateway VPC complies with company-specific requirements and it will only host the **Shared Application Load Balancer**, **Application Load Balancer listeners** and a **Route53 Private Hosted Zone** (apollotyres.com). Typically, the workload VPC should be used to configure any other AWS Service, e.g. ECS tasks, RDS instances, AWS Elasticache, 

#### SSM Parameters

We provide the following SSM Parameters
| Parameter | Description |
|-----------|-------------|
| `/network/vpc_id` | Workload VPC ID |
| `/network/vpc_cidr_block` | Workload VPC CIDR |
| `/network/vpc_private_subnet_ids` | Workload VPC private subnet IDs |
| `/network/gateway_vpc_id` | Gateway VPC ID |
| `/network/gateway_vpc_cidr_block` | Gateway VPC CIDR |
| `/network/gateway_vpc_private_subnet_ids` | Gateway VPC private subnet IDs |

SSM parameters can be used as follows:

```hcl
data "aws_ssm_parameter" "vpc_id" {
  name           = "/network/vpc_id"
}

data "aws_ssm_parameter" "vpc_cidr_block" {
  name           = "/network/vpc_cidr_block"
}

resource "aws_security_group" "procopt_rds_sg" {
  vpc_id      = data.aws_ssm_parameter.vpc_id.insecure_value
  name        = "my-postgres-security-group"
  description = "Allows inbound traffic from VPC CIDR to postgres port 5432"

  ingress {
    description = "Allow postgres port 5432 from the private subnets CIDR"
    from_port   = local.procopt_rds_port
    to_port     = local.procopt_rds_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_ssm_parameter.vpc_cidr_block.value]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Commands

```bash
# Initialize a workspace
cd dev/eu-west-1/<workspace>
terraform init

# Plan changes
terraform plan

# Apply changes (CI does this on merge to main)
terraform apply

# Format all Terraform files
terraform fmt -recursive

# Validate a workspace
terraform validate
```
