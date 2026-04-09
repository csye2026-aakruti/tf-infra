resource "aws_lambda_function" "email_verification" {
  function_name = "${var.project}-${var.env}-${var.name_suffix}-email-verification"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  environment {
    variables = {
      DYNAMODB_TABLE  = aws_dynamodb_table.email_tracking.name
      MAILGUN_API_KEY = var.mailgun_api_key
      MAILGUN_DOMAIN  = var.mailgun_domain
      VERIFY_BASE_URL = "http://${aws_route53_record.app.name}"
    }
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-email-verification"
  }
}