variable "domain" {
  description = "Primary domain name (e.g. findora.nl)"
  type        = string
}

variable "cname_name" {
  description = "CNAME record name for Gmail domain verification"
  type        = string
}

variable "cname_value" {
  description = "CNAME record value for Gmail domain verification"
  type        = string
}
