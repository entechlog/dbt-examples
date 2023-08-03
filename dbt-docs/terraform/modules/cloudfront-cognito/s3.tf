# IAM policy for s3 bucket
data "aws_iam_policy_document" "s3_read_only_access" {

  statement {
    sid     = "allow-read-access-cf"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.app.arn}",
      "${aws_s3_bucket.app.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.app.iam_arn}"]
    }
  }

}

# Create an S3 bucket
resource "aws_s3_bucket" "app" {
  bucket        = local.resource_name_prefix
  force_destroy = true
}

# Configure server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Apply an S3 bucket policy to restrict access to the bucket
resource "aws_s3_bucket_policy" "app" {
  bucket = aws_s3_bucket.app.bucket
  policy = data.aws_iam_policy_document.s3_read_only_access.json
}

# Configure the S3 bucket as a static website hosting endpoint
resource "aws_s3_bucket_website_configuration" "app" {
  bucket = aws_s3_bucket.app.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Configure Cross-Origin Resource Sharing (CORS) for the bucket
resource "aws_s3_bucket_cors_configuration" "app" {
  bucket = aws_s3_bucket.app.bucket

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    max_age_seconds = 300
  }
}

# Apply public access block settings to the bucket
resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload sample docs
resource "aws_s3_object" "app" {
  for_each     = fileset("../uploads/docs/", "*")
  bucket       = aws_s3_bucket.app.id
  key          = each.value
  source       = "../uploads/docs/${each.value}"
  content_type = lookup(local.mime_type_mappings, regex("\\.[^.]+$", each.value), null)
  etag         = filemd5("../uploads/docs/${each.value}")
}