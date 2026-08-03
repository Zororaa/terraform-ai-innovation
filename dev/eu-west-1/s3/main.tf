provider "aws" {
  region = var.aws_region
}

data "aws_partition" "current" {}

data "aws_organizations_organization" "current" {}

data "aws_caller_identity" "current" {}

locals {
  management_account_id = data.aws_organizations_organization.current.master_account_id

  tags = {
    "Owner" : "ai-innovation",
    "Environment" : var.env
    "Repository" : "terraform-ai-innovation-genai",
    "CostCenter" : "genai",
    "Team" : "apexon",
  }

  current_account_name = "ai-innovation-internal-${var.env}"
  parameter_prefix     = "/${var.project_name}/${var.env}/shared"

  project_name         = lower(var.project_name)
  environment          = lower(var.env)
  aws_region_shortcode = lower(var.aws_region_shortcode)

  active_name = join("-", [
    local.project_name,
    local.environment,
    local.aws_region_shortcode
  ])

  bucket_name = lower(
    join("-", [
      local.active_name,
      data.aws_caller_identity.current.account_id
    ])
  )

}
