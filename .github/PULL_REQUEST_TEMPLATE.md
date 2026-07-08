## Work Item ID



## Summary of Change



## Description of Change



---

## PR Review Guidelines

- `terraform fmt` has been run and formatting is correct
- `terraform validate` passes without errors
- `terraform plan` output has been reviewed and contains only intended changes
- All resources include required tags (Owner, Environment, Repository, CostCenter)
- No hardcoded values — use variables and locals for environment-specific configuration
- No secrets, credentials, or sensitive values committed (use GitHub Actions secrets or SSM)
- S3 backend key matches the workspace directory path (`<env>/<region>/<workspace>/terraform.tfstate`)
- Provider and Terraform version constraints are present in `versions.tf`
- New resources use descriptive naming conventions consistent with existing infrastructure
- Least-privilege IAM policies — no `*` actions or resources unless explicitly justified
- Security groups follow least-privilege (no `0.0.0.0/0` ingress unless required and documented)
- State-affecting changes (imports, moves, replacements) are called out in the PR description
- Cross-workspace dependencies use SSM Parameter Store, not hardcoded ARNs or IDs
- Destructive changes (resource replacement, deletion) are intentional and acknowledged

