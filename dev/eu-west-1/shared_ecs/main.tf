# ------------------------------------------------------
# Locals
# ------------------------------------------------------
locals {
  tags = {
    Owner       = "ai-innovation"
    Environment = var.env
    Repository  = "terraform-ai-innovation-genai"
    CostCenter  = "genai"
  }
  cluster_name = "shared-ecs-${var.env}"
}


######################################################
#                    ECS Cluster
######################################################
resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  tags = local.tags
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

######################################################
#                    SSM Parameters
######################################################
locals {
  ssm_parameters = {
    cluster_name = aws_ecs_cluster.ecs_cluster.name
    cluster_id   = aws_ecs_cluster.ecs_cluster.name
    cluster_arn  = aws_ecs_cluster.ecs_cluster.arn
  }
}

resource "aws_ssm_parameter" "ecs" {
  for_each = local.ssm_parameters

  name  = "/shared/ecs/${each.key}"
  type  = "String"
  value = each.value

  tags = local.tags
}
