data "aws_cloudfront_distribution" "cdn" {
  id = var.cdn_distribution_id
}

# A record for the root domain using a CloudFront alias
resource "aws_route53_record" "findora_root_a" {
  zone_id = var.route53_zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = var.cdn_alias
    zone_id                = data.aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# A record for the www subdomain using the same CloudFront alias
resource "aws_route53_record" "findora_www_a" {
  zone_id = var.route53_zone_id
  name    = var.alt_domain
  type    = "A"

  alias {
    name                   = var.cdn_alias
    zone_id                = data.aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# Alias A record to route api.findora.nl to the API Gateway custom domain.
# Ensures frontend can communicate with backend using a clean subdomain.
resource "aws_route53_record" "api_domain" {
  zone_id = var.route53_zone_id
  name    = "api.${var.domain}"
  type    = "A"

  alias {
    name                   = var.api_gateway_domain_name
    zone_id                = var.api_gateway_hosted_zone_id
    evaluate_target_health = false
  }
}
