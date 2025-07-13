output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}

output "cdn_alias" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "cdn_distribution_id" {
  value = aws_cloudfront_distribution.cdn.id
}

output "zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "bucket_name" {
  value = aws_s3_bucket.ui_bucket.bucket
}