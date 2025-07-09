variable "lambda_package_path" {
  description = "Path to the packaged Lambda zip file"
  type        = string
}

variable "openai_api_key" {
  description = "OpenAI API key for the Lambda environment"
  type        = string
  sensitive   = true
}