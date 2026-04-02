resource "aws_dynamodb_table" "email_tracking" {
  name         = "${var.project}-${var.env}-${var.name_suffix}-email-tracking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "token"

  attribute {
    name = "token"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-email-tracking"
  }
}