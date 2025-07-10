provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket         = "findora-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "findora-terraform-locks"
    encrypt        = true
  }
}

module "feedback" { 
  source = "./modules/feedback"
}

module "lambda_core" {
  source             = "./modules/lambda-core"
  lambda_package_path = "../core/dist/lambda.zip"
  openai_api_key     = var.openai_api_key
}
