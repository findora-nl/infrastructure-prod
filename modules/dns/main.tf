data "aws_cloudfront_distribution" "cdn" {
  id = var.cdn_distribution_id
}

resource "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_route53_record" "findora_root_a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = var.cdn_alias
    zone_id                = data.aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "findora_www_a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.alt_domain
  type    = "A"

  alias {
    name                   = var.cdn_alias
    zone_id                = data.aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "google_site_verification" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = 300
  records = [var.google_verification_txt]
}

resource "aws_route53_record" "google_hosted_verification" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.cname_name
  type    = "CNAME"
  ttl     = 300
  records = [var.cname_value]
}

resource "aws_route53_record" "mx_google" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain
  type    = "MX"
  ttl     = 300
  records = ["1 SMTP.GOOGLE.COM."]
}
