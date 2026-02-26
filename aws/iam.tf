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