variable "domain" {
  description = "Primary domain name (e.g. findora.nl)"
  type        = string
}

variable "alt_domain" {
  description = "Alternate domain (e.g. www.findora.nl)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
