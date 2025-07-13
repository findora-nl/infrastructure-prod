provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

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
  source              = "./modules/lambda-core"
  lambda_package_path = "../core/dist/lambda.zip"
  openai_api_key      = var.openai_api_key
}

module "ui_hosting" {
  source          = "./modules/ui-hosting"
  domain          = "findora.nl"
  alt_domain      = "www.findora.nl"
}

module "dns" {
  source       = "./modules/dns"
  domain       = "findora.nl"
  alt_domain   = "www.findora.nl"
  cdn_alias = module.ui_hosting.cdn_alias
  cdn_distribution_id = module.ui_hosting.cdn_distribution_id
  google_verification_txt = "google-site-verification=ICfkcNHkDkRqXmQQjmUQDL1VChjbUGENlQ3Tqj_PIlQ"
  cname_name              = "lz64adi3tzif"
  cname_value             = "gv-24z3wo275swgiv.dv.googlehosted.com."
}
