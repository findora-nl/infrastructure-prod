variable "lambda_package_path" {
  description = "Path to the packaged Lambda zip file"
  type        = string
}

variable "openai_api_key" {
  description = "OpenAI API key for the Lambda environment"
  type        = string
  sensitive   = true
}
variable "domain" {
  description = "Base domain name for the API (e.g., findora.nl)"
  type        = string
}

variable "api_cert_arn" {
  description = "ARN of the ACM certificate for the API Gateway domain"
  type        = string
}
