# Project: terraform-ai-innovation-genai

AWS infrastructure managed via Terraform for the `ai-innovation-genai-dev` and `ai-innovation-genai-prod` accounts.

## Structure

```
dev/
  eu-west-1/
    <workspace>/       # Each subdirectory is an independent Terraform workspace
      main.tf
      variables.tf
      versions.tf
      backend.tf
.github/
  workflows/           # CI pipelines per environment/region
```

## Conventions

- Each Terraform workspace lives in `<env>/<region>/<workspace>/`
- Standard file layout per workspace: `main.tf`, `variables.tf`, `versions.tf`, `backend.tf`
- All resources must include standard tags: Owner, Environment, Repository, CostCenter
- CI uses shared reusable workflows from `atl-ai-innovation/shared-workflows`
- Changes to a region directory trigger the corresponding GitHub Actions pipeline

## Commands

- `terraform init` — initialize a workspace (run from within the workspace directory)
- `terraform plan` — preview changes
- `terraform fmt -check` — check formatting
- `terraform validate` — validate configuration

## Guidelines

- Never commit `.tfvars` files or state files (covered by `.gitignore`)
- Use variables for environment-specific values; keep `main.tf` focused on resource definitions
- Target AWS region `eu-west-1` for dev workloads
- PRs targeting `main` trigger plan; merges to `main` trigger apply
