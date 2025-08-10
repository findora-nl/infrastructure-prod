terraform {
  backend "s3" {
    bucket         = "findora-terraform-state"
    key            = "infrastructure/prod.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "findora-terraform-locks-prod"
    encrypt        = true
  }
}