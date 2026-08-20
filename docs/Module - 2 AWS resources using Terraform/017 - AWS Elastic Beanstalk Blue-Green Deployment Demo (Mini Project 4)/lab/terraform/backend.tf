terraform {
  backend "s3" {
    bucket       = "my-third-terraform-backend-bucket"
    key          = "dev/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}
