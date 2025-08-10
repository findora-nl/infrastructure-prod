resource "aws_dynamodb_table" "feedback" {
  name         = "${replace(var.domain, ".", "-")}-feedback"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "Findora"
    Module  = "feedback"
  }
}
variable "domain" {
  description = "Base domain name (e.g., findora.nl)"
  type        = string
}