data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

################################################################################
# KMS Key for RDS secret encryption
################################################################################

data "aws_iam_policy_document" "kms_rds" {
  statement {
    sid    = "EnableAccountPermissions"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_kms_key" "rds_secret" {
  description = "KMS key used to encrypt the ${var.project_name} ${var.environment} rds instance"

  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  multi_region            = var.multi_region

  policy = data.aws_iam_policy_document.kms_rds.json

  tags = merge(
    var.tags,
    {
      Name    = "${var.project_name}-${var.environment}-rds-kms"
      Service = "rds"
      Purpose = "rds instance for atlas"
    }
  )
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_name}-${var.environment}-rds"
  target_key_id = aws_kms_key.rds_secret.key_id
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "vpc_rds_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.active_name}-database-sg"
  description = "Allows inbound traffic from VPC CIDR to postgres port 5432"

  ingress {
    description = "Allow postgres port 5432 from the private subnets CIDR"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${var.active_name}-database-sg" }, var.tags)
}

################################################################################
# DB Subnet Group
################################################################################

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.active_name}-rds-subnet-group"
  description = "Private subnet group for PostgreSQL RDS"

  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.active_name}-rds-subnet-group"
    }
  )
}

################################################################################
# RDS Password
################################################################################

resource "random_password" "atlas_db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

################################################################################
# RDS Instance
################################################################################

module "rds_instance" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.13.1"

  identifier = "${var.active_name}-postgres"

  db_name  = replace("${var.active_name}_postgres", "-", "_")
  username = var.db_admin_name
  port     = var.db_port

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.vpc_rds_sg.id]
  publicly_accessible    = false

  kms_key_id                  = aws_kms_key.rds_secret.arn
  manage_master_user_password = false
  password                    = random_password.atlas_db_password.result


  engine         = "postgres"
  engine_version = var.engine_version
  family         = "postgres${var.engine_version}"
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"

  create_db_parameter_group = true
  availability_zone         = var.environment == "dev" ? "${var.aws_region}a" : null
  multi_az                  = var.environment == "prod"
  parameters                = var.db_parameters

  enabled_cloudwatch_logs_exports        = var.enabled_cloudwatch_logs_exports
  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cloudwatch_log_group_class             = var.cloudwatch_log_group_class
  cloudwatch_log_group_skip_destroy      = var.cloudwatch_log_group_skip_destroy
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

}
