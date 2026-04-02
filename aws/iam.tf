# IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "${var.project}-${var.env}-${var.name_suffix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-ec2-role"
  }
}

# IAM policy - least privilege S3 access scoped to the specific bucket
resource "aws_iam_policy" "s3_policy" {
  name        = "${var.project}-${var.env}-${var.name_suffix}-s3-policy"
  description = "Allow EC2 to access S3 bucket for syllabus uploads"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.app.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.app.arn
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "s3_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

# Instance profile — this is what gets attached to the EC2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-${var.env}-${var.name_suffix}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# IAM policy for CloudWatch agent
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "${var.project}-${var.env}-${var.name_suffix}-cloudwatch-policy"
  description = "Allow EC2 to publish logs and metrics to CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach CloudWatch policy to role
resource "aws_iam_role_policy_attachment" "cloudwatch_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.project}-${var.env}-${var.name_suffix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-lambda-role"
  }
}

# IAM policy for Lambda - least privilege
resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.project}-${var.env}-${var.name_suffix}-lambda-policy"
  description = "Allow Lambda to write CloudWatch logs and access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Resource = aws_dynamodb_table.email_tracking.arn
      }
    ]
  })
}

# Attach policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# IAM policy for EC2 to publish to SNS
resource "aws_iam_policy" "sns_publish_policy" {
  name        = "${var.project}-${var.env}-${var.name_suffix}-sns-publish-policy"
  description = "Allow EC2 to publish messages to SNS topic"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.user_verification.arn
      }
    ]
  })
}

# Attach SNS publish policy to EC2 role
resource "aws_iam_role_policy_attachment" "sns_publish_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}