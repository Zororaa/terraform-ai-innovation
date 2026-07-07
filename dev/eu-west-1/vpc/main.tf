provider "aws" {
  region = var.aws_region
}

locals {
  tags = {
    "Owner" : "ai-innovation",
    "Environment" : var.env
    "Repository" : "terraform-ai-innovation-genai",
    "CostCenter" : "shared"
  }
}
