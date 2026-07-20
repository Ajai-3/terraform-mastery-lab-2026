terraform {
  backend "s3" {
    bucket       = "terraform-backend-bucket-mini-project-2"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
