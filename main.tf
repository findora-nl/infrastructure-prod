provider "aws" {
  region = "eu-west-1" # You can adjust this to your preferred AWS region
}

module "feedback" { 
  source = "./modules/feedback"
}