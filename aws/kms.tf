resource "aws_kms_key" "ec2" {
  description             = "KMS key for EC2 EBS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::631259293293:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EC2 to use the key"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-ec2-key"
  }
}

resource "aws_kms_alias" "ec2" {
  name          = "alias/${var.project}-${var.env}-${var.name_suffix}-ec2"
  target_key_id = aws_kms_key.ec2.key_id
}

resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-rds-key"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project}-${var.env}-${var.name_suffix}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-s3-key"
  }
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project}-${var.env}-${var.name_suffix}-s3"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-secrets-key"
  }
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.project}-${var.env}-${var.name_suffix}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}