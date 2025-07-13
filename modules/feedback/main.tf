resource "aws_dynamodb_table" "feedback" {
  name         = "findora-feedback"
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