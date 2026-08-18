# Shared ECS

Provisions a shared ECS Fargate cluster for hosting application services.

## Resources

- **ECS Cluster** (`shared-ecs-{env}`) with Fargate capacity provider
- Container Insights disabled in dev

## SSM Parameters

### Consumed

None.

### Produced

| Parameter | Description |
|-----------|-------------|
| `/shared/ecs/cluster_name` | ECS cluster name |
| `/shared/ecs/cluster_id` | ECS cluster ID |
| `/shared/ecs/cluster_arn` | ECS cluster ARN |
