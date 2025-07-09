provider "aws" {
  region = "eu-west-1" # You can adjust this to your preferred AWS region
}

module "feedback" { 
  source = "./modules/feedback"
}

module "lambda_core" {
  source             = "./modules/lambda-core"
  lambda_package_path = "../core/dist/lambda.zip"
  openai_api_key     = var.openai_api_key
}
