resource "random_uuid" "bucket_name" {}

resource "aws_s3_bucket" "app" {
  bucket        = random_uuid.bucket_name.result
  force_destroy = true

  tags = {
    Name        = "${var.project}-${var.env}-${var.name_suffix}-bucket"
    Environment = var.env
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle policy: transition to STANDARD_IA after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}