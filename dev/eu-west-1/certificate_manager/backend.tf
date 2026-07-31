terraform {
  backend "s3" {
    bucket       = "ai-innovation-terraform-state-446437544809"
    key          = "dev/eu-west-1/certificate_manager/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}
