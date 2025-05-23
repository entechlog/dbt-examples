data "aws_iam_policy_document" "s3_read_only_access" {
  statement {
    sid     = "allow-read-access-cf"
    actions = ["s3:GetObject"]
    resources = [
      aws_s3_bucket.app.arn,
      "${aws_s3_bucket.app.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.app.iam_arn]
    }
  }
}

resource "aws_s3_bucket" "app" {
  bucket        = "${var.name_prefix}-${var.app_code}"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "app" {
  bucket = aws_s3_bucket.app.bucket
  policy = data.aws_iam_policy_document.s3_read_only_access.json
}

resource "aws_s3_bucket_website_configuration" "app" {
  bucket = aws_s3_bucket.app.bucket

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "app" {
  bucket = aws_s3_bucket.app.bucket

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    max_age_seconds = 300
  }
}

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