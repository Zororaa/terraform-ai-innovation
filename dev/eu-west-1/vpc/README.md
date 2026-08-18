# VPC

Provisions the core networking layer for the GenAI workload account: two private-only VPCs connected to the shared Transit Gateway.

## Architecture

```
Hub VPC (shared-services) ──── TGW ──── Workload VPC (ECS, RDS, ElastiCache)
                                    └── Gateway VPC (ALB, Route 53)
```

### Workload VPC

Private-only VPC hosting application workloads (ECS tasks, RDS, ElastiCache). CIDR and subnet configuration read from the management account's RAM-shared SSM parameters.

### Gateway VPC

Private-only VPC hosting only the shared ALB and Route 53 private hosted zone. Separated from the workload VPC to satisfy network segmentation requirements.

### Transit Gateway Attachments

Both VPCs attach to the shared Transit Gateway. All private route tables route `0.0.0.0/0` through the TGW for internet access via hub NAT gateways.

## VPC Endpoints

| Type | Services |
|------|----------|
| Gateway | S3, DynamoDB |
| Interface | CodeArtifact, ECR (api + dkr), CloudWatch Logs, SageMaker, API Gateway, Systems Manager |

All endpoint policies are scoped to the AWS Organization.

## VPC Flow Logs

Exported to S3 in Parquet format with Hive-compatible partitions, per-hour granularity, and 90-day retention.

## SSM Parameters

### Consumed (from aws-org-management via RAM)

| Parameter | Description |
|-----------|-------------|
| `/shared-networking-config/spoke_vpcs/workload_vpc/ai-innovation-genai-{env}` | Workload VPC config (CIDR, subnets) |
| `/shared-networking-config/spoke_vpcs/gateway_vpc/ai-innovation-genai-{env}` | Gateway VPC config (CIDR, subnets) |

### Produced

| Parameter | Description |
|-----------|-------------|
| `/network/vpc_id` | Workload VPC ID |
| `/network/vpc_cidr_block` | Workload VPC CIDR |
| `/network/private_subnet_ids` | Workload VPC private subnet IDs (comma-separated) |
| `/network/gateway_vpc_id` | Gateway VPC ID |
| `/network/gateway_vpc_cidr_block` | Gateway VPC CIDR |
| `/network/gateway_vpc_private_subnet_ids` | Gateway VPC private subnet IDs (comma-separated) |

These parameters are consumed by: [shared_alb](../shared_alb/README.md), [rds](../rds/README.md), [sql_executor](../sql_executor/README.md), [secure-browser](../secure-browser/README.md).
