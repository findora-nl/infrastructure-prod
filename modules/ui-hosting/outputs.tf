output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_certificate_arn" {
  value       = aws_acm_certificate_validation.cert_validation.certificate_arn
  description = "Certificate in us-east-1 for CloudFront"
}

output "regional_certificate_arn" {
  value       = aws_acm_certificate_validation.cert_regional_validation.certificate_arn
  description = "Certificate in eu-west-1 for API Gateway"
}

output "cdn_alias" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "cdn_distribution_id" {
  value = aws_cloudfront_distribution.cdn.id
}

output "bucket_name" {
  value = aws_s3_bucket.ui_bucket.bucket
}