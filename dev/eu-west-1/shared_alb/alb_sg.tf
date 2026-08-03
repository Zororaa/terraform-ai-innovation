resource "aws_security_group" "shared_alb_sg" {
  name        = "${local.shared_alb_name}-sg"
  description = "Security group for shared ALB"
  vpc_id      = data.aws_ssm_parameter.gateway_vpc_id.value

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_ssm_parameter.gateway_vpc_cidr_block.value, data.aws_ssm_parameter.workload_vpc_cidr_block.value]
    description = "Allow HTTP from specified CIDR blocks"
  }

  # Allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_ssm_parameter.gateway_vpc_cidr_block.value, data.aws_ssm_parameter.workload_vpc_cidr_block.value]
    description = "Allow HTTPS from specified CIDR blocks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.shared_alb_name}-sg"
    }
  )
}
