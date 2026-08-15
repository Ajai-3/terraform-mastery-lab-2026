terraform {
  backend "s3" {
    bucket       = "my-first-terraform-backend-bucket-1"
    key          = "dev/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}
