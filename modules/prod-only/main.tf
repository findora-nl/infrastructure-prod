resource "aws_route53_zone" "main" {
  name          = "findora.nl"
  comment       = "Managed by Terraform"
  force_destroy = false
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

resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain
  type    = "TXT"
  ttl     = 300
  records = ["v=spf1 include:_spf.google.com ~all"]
}