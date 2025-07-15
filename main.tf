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

# Main Route53 hosted zone for the domain
resource "aws_route53_zone" "main" {
  name = "findora.nl"
}

module "feedback" {
  source = "./modules/feedback"
}

module "lambda_core" {
  source              = "./modules/lambda-core"
  lambda_package_path = "../core/dist/lambda.zip"
  openai_api_key      = var.openai_api_key
  domain              = "findora.nl"
  api_cert_arn        = module.ui_hosting.regional_certificate_arn
}

module "ui_hosting" {
  source          = "./modules/ui-hosting"
  domain          = "findora.nl"
  alt_domain      = "www.findora.nl"
  route53_zone_id = aws_route53_zone.main.zone_id
}

module "dns" {
  source                     = "./modules/dns"
  domain                     = "findora.nl"
  alt_domain                 = "www.findora.nl"
  cdn_alias                  = module.ui_hosting.cdn_alias
  cdn_distribution_id        = module.ui_hosting.cdn_distribution_id
  google_verification_txt    = "google-site-verification=ICfkcNHkDkRqXmQQjmUQDL1VChjbUGENlQ3Tqj_PIlQ"
  cname_name                 = "lz64adi3tzif"
  cname_value                = "gv-24z3wo275swgiv.dv.googlehosted.com."
  route53_zone_id            = aws_route53_zone.main.zone_id
  api_gateway_domain_name    = module.lambda_core.api_gateway_domain_name
  api_gateway_hosted_zone_id = module.lambda_core.api_gateway_hosted_zone_id
}
