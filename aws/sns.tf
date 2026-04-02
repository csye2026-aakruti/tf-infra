resource "aws_sns_topic" "user_verification" {
  name = "${var.project}-${var.env}-${var.name_suffix}-user-verification"

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-user-verification"
  }
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.user_verification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_verification.arn
}

resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_verification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_verification.arn
}