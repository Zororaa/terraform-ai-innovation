provider "aws" {
  region = var.aws_region
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/network/gateway_vpc_id"
}

data "aws_ssm_parameter" "private_subnets" {
  name = "/network/gateway_vpc_private_subnet_ids"
}

data "aws_ssm_parameter" "vpc_cidr_block" {
  name = "/network/gateway_vpc_cidr_block"
}

locals {
  tags = {
    "Owner"       = "ai-innovation"
    "Environment" = var.env
    "Repository"  = "terraform-ai-innovation-genai"
    "CostCenter"  = "shared"
  }

  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnets.insecure_value)
}

##################################
# Setup Shared AWS Secure Browser
##################################

locals {
  # See https://chromeenterprise.google/policies for all available options
  browser_policy = {
    chromePolicies = {
      ManagedBookmarks = {
        value = [
          {
            name = "AI Innovation AWS Console"
            url  = "https://atl-ai-innovation-aws.apollotyres.com"
          }
        ]
      }
      RestoreOnStartup = {
        value = 5
      }
      ExtensionInstallBlocklist = {
        value = []
      }
      ExtensionInstallAllowlist = {
        value = []
      }
      AllowDeletingBrowserHistory = {
        value = true
      }
      IncognitoModeAvailability = {
        value = 0 # available
      }
    }
  }
}

module "aws_secure_browser_atlas" {
  source                  = "git::https://github.com/atl-ai-innovation/terraform-modules.git//secure-browser?ref=v0.9.0"
  max_concurrent_sessions = 5
  private_subnet_ids      = local.private_subnet_ids
  team                    = "atlas-developers"
  vpc_id                  = data.aws_ssm_parameter.vpc_id.insecure_value
  vpc_cidr_block          = data.aws_ssm_parameter.vpc_cidr_block.insecure_value
  idp_saml_metadata_xml   = file("${path.module}/idp-metadata/genai-dev-eu-west-1.xml")
  browser_policy          = jsonencode(local.browser_policy)

  workspaces_user_settings = {
    copy_allowed                       = "Enabled"
    download_allowed                   = "Enabled"
    paste_allowed                      = "Enabled"
    print_allowed                      = "Enabled"
    upload_allowed                     = "Enabled"
    deep_link_allowed                  = "Enabled"
    disconnect_timeout_in_minutes      = 120
    idle_disconnect_timeout_in_minutes = 60
  }

  tags = merge(
    { "Team" = "shared" }, local.tags
  )
}