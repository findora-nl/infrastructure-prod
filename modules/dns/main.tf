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

# SPF TXT record for Google Workspace email sending policy
resource "aws_route53_record" "spf" {
  zone_id = var.route53_zone_id
  name    = var.domain
  type    = "TXT"
  ttl     = 300
  records = ["v=spf1 include:_spf.google.com ~all"]
}

# Google-hosted verification CNAME record for domain verification
resource "aws_route53_record" "google_hosted_verification" {
  zone_id = var.route53_zone_id
  name    = var.cname_name
  type    = "CNAME"
  ttl     = 300
  records = [var.cname_value]
}

# MX record to route email to Google Workspace mail servers
resource "aws_route53_record" "mx_google" {
  zone_id = var.route53_zone_id
  name    = var.domain
  type    = "MX"
  ttl     = 300
  records = ["1 SMTP.GOOGLE.COM."]
}
