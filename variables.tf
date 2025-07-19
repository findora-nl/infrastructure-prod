variable "domain" {
  type        = string
  description = "Base domain name"
}

variable "alt_domain" {
  type        = string
  description = "Alternate domain name"
}

variable "openai_api_key" {
  type        = string
  sensitive   = true
  description = "OpenAI API key"
}

variable "google_verification_txt" {
  type        = string
  description = "Google TXT verification value"
}

variable "cname_name" {
  type        = string
  description = "Google verification CNAME record name"
}

variable "cname_value" {
  type        = string
  description = "Google verification CNAME record value"
}

variable "enable_prod_only" {
  type        = bool
  description = "Whether to enable prod-only resources"
}
