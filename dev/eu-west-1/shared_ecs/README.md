# Shared ECS Cluster

This workspace provisions a shared ECS Fargate cluster for the `ai-innovation-genai-dev` account in `eu-west-1`.

## Resources

- **ECS Cluster** (`shared-ecs-dev`) with Fargate capacity provider

## SSM Parameters

| Parameter | Description |
|-----------|-------------|
| `/shared/ecs/cluster_name` | ECS cluster name |
| `/shared/ecs/cluster_id` | ECS cluster ID |
| `/shared/ecs/cluster_arn` | ECS cluster ARN |

## SSM Dependencies

| Parameter | Description |
|-----------|-------------|
| `/network/vpc_id` | VPC ID (read) |
| `/network/private_subnet_ids` | Private subnet IDs (read) |
