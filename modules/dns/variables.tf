variable "domain" {
  description = "Primary domain name (e.g. findora.nl)"
  type        = string
}

variable "alt_domain" {
  description = "Alternate domain (e.g. www.findora.nl)"
  type        = string
}

variable "route53_zone_id" {
  description = "ID of the shared Route53 hosted zone"
  type        = string
}

variable "cdn_alias" {
  description = "CloudFront domain name used as alias target"
  type        = string
}

variable "cdn_distribution_id" {
  description = "The ID of the CloudFront distribution"
  type        = string
}

variable "google_verification_txt" {
  description = "TXT record for Google site verification"
  type        = string
}

variable "cname_name" {
  description = "Subdomain name for Google verification CNAME"
  type        = string
}

variable "cname_value" {
  description = "Target value for Google verification CNAME"
  type        = string
}