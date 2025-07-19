provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  region = "eu-west-1"
}

module "prod-only" {
  count       = var.enable_prod_only ? 1 : 0
  source      = "./modules/prod-only"
  domain      = var.domain
  cname_name  = var.cname_name
  cname_value = var.cname_value
}

data "aws_route53_zone" "main" {
  count        = var.enable_prod_only ? 0 : 1
  name         = "findora.nl"
  private_zone = false
}

locals {
  route53_zone_id = var.enable_prod_only ? module.prod-only[0].zone_id : data.aws_route53_zone.main[0].zone_id
}

module "feedback" {
  source = "./modules/feedback"
  domain = var.domain
}

module "lambda_core" {
  source              = "./modules/lambda-core"
  lambda_package_path = "../core/dist/lambda.zip"
  openai_api_key      = var.openai_api_key
  domain              = var.domain
  api_cert_arn        = module.ui_hosting.regional_certificate_arn
}

module "ui_hosting" {
  source          = "./modules/ui-hosting"
  domain          = var.domain
  alt_domain      = var.alt_domain
  route53_zone_id = local.route53_zone_id
}

module "dns" {
  source                     = "./modules/dns"
  domain                     = var.domain
  alt_domain                 = var.alt_domain
  cdn_alias                  = module.ui_hosting.cdn_alias
  cdn_distribution_id        = module.ui_hosting.cdn_distribution_id
  google_verification_txt    = "google-site-verification=ICfkcNHkDkRqXmQQjmUQDL1VChjbUGENlQ3Tqj_PIlQ"
  cname_name                 = var.cname_name
  cname_value                = var.cname_value
  route53_zone_id            = local.route53_zone_id
  api_gateway_domain_name    = module.lambda_core.api_gateway_domain_name
  api_gateway_hosted_zone_id = module.lambda_core.api_gateway_hosted_zone_id
}