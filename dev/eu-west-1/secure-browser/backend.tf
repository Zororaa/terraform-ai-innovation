terraform {
  backend "s3" {
    bucket       = "ai-innovation-terraform-state-446437544809"
    key          = "dev/eu-west-1/secure-browser/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = false
  }
}
