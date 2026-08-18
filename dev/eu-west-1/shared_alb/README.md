# Shared ALB

Provisions a shared internal Application Load Balancer in the Gateway VPC, along with a Route 53 private hosted zone for internal DNS resolution.

## Architecture

```
On-Prem / Spoke VPCs ──── TGW ──── Gateway VPC ──── ALB (HTTPS:443) ──── Listener Rules ──── Target Groups
```

## Resources

- **Internal ALB** — Deployed in Gateway VPC private subnets. Single entry point for all internal HTTP/HTTPS traffic.
- **HTTPS Listener** — Port 443 with `*.apollotyres.com` wildcard certificate. Default action returns 404; services register via listener rules.
- **ALB Security Group** — Allows HTTP/HTTPS from VPC CIDRs and on-premises CIDRs. Permits all outbound.
- **Route 53 Private Hosted Zone** — `apollotyres.com`, associated with both Gateway and Workload VPCs.

## Security Group Rules

| Direction | Port | Source |
|-----------|------|--------|
| Ingress | 80, 443 | Gateway VPC CIDR, Workload VPC CIDR, on-prem CIDRs |
| Egress | All | 0.0.0.0/0 |

On-prem CIDRs are read dynamically from the RAM-shared SSM parameter `/shared-networking-config/on_prem_cidrs` (managed in [aws-org-management](https://github.com/atl-ai-innovation/aws-org-management)).

## SSM Parameters

### Consumed

| Parameter | Source | Description |
|-----------|--------|-------------|
| `/network/vpc_id` | [vpc](../vpc/README.md) | Workload VPC ID (for Route 53 zone association) |
| `/network/vpc_cidr_block` | [vpc](../vpc/README.md) | Workload VPC CIDR (for SG rules) |
| `/network/gateway_vpc_id` | [vpc](../vpc/README.md) | Gateway VPC ID (for ALB deployment) |
| `/network/gateway_vpc_private_subnet_ids` | [vpc](../vpc/README.md) | Gateway VPC subnets (for ALB placement) |
| `/network/gateway_vpc_cidr_block` | [vpc](../vpc/README.md) | Gateway VPC CIDR (for SG rules) |
| `/shared/certificates/apollotyres_wildcard_arn` | [certificate_manager](../certificate_manager/README.md) | ACM certificate ARN |
| `/shared-networking-config/on_prem_cidrs` | [aws-org-management](https://github.com/atl-ai-innovation/aws-org-management) | On-prem CIDR list (cross-account via RAM) |

### Produced

| Parameter | Description |
|-----------|-------------|
| `/shared/shared_alb/id` | ALB ID |
| `/shared/shared_alb/arn` | ALB ARN |
| `/shared/shared_alb/dns_name` | ALB DNS name |
| `/shared/shared_alb/zone_id` | ALB hosted zone ID (for Route 53 alias records) |
| `/shared/shared_alb/security_group_id` | ALB security group ID |
| `/shared/shared_alb/https_listener_arn` | HTTPS listener ARN (for registering listener rules) |
| `/shared/hosted_zone/private_hosted_zone_name` | Private hosted zone name (`apollotyres.com`) |
| `/shared/hosted_zone/private_hosted_zone_id` | Private hosted zone ID |
