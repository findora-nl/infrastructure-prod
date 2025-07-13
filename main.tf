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

resource "aws_route53_zone" "main" {
  name = "findora.nl"
}

module "feedback" { 
  source = "./modules/feedback"
}

module "lambda_core" {
  source             = "./modules/lambda-core"
  lambda_package_path = "../core/dist/lambda.zip"
  openai_api_key     = var.openai_api_key
}

# S3 bucket for UI hosting
resource "aws_s3_bucket" "ui_bucket" {
  bucket = "findora.nl"

  tags = {
    Name = "Findora UI Bucket"
  }
}

# S3 Bucket Website configuration
resource "aws_s3_bucket_website_configuration" "ui_website" {
  bucket = aws_s3_bucket.ui_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "ui_ownership" {
  bucket = aws_s3_bucket.ui_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 Bucket Public Access Block (allowing public access)
resource "aws_s3_bucket_public_access_block" "ui_public_access" {
  bucket = aws_s3_bucket.ui_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "ui_bucket_policy" {
  bucket = aws_s3_bucket.ui_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.ui_bucket.arn}/*"]
      }
    ]
  })
}


# ACM certificate in us-east-1 for CloudFront
resource "aws_acm_certificate" "cert" {
  provider          = aws.us-east-1
  domain_name       = "findora.nl"
  validation_method = "DNS"

  subject_alternative_names = ["www.findora.nl"]

  tags = {
    Name = "Findora UI Certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route53 record for DNS validation
resource "aws_route53_record" "findora_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# resource "aws_acm_certificate_validation" "cert_validation" {
#   provider                = aws.us-east-1
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.findora_cert_validation : record.fqdn]
# }

# CloudFront distribution
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.ui_bucket.bucket_regional_domain_name
    origin_id   = "S3-findora-ui"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Findora UI CDN"
  default_root_object = "index.html"

  # aliases = ["findora.nl", "www.findora.nl"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-findora-ui"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "Findora CDN"
  }

  # depends_on = [aws_acm_certificate_validation.cert_validation]
}
