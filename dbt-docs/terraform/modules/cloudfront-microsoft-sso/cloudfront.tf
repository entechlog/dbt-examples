resource "aws_cloudfront_origin_access_identity" "app" {
  comment = "${var.app_code} CloudFront origin access identity"
}

resource "aws_cloudfront_distribution" "app" {
  origin {
    domain_name = aws_s3_bucket.app.bucket_regional_domain_name
    origin_id   = "s3"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.app.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.app_code} CloudFront distribution"
  default_root_object = "index.html"

  # Behavior for SSO callback handling – triggered on SSO provider redirect.
  ordered_cache_behavior {
    path_pattern           = "callback*"
    target_origin_id       = "s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
    dynamic "lambda_function_association" {
      for_each = var.enable_auth_flag ? [1] : []
      content {
        # viewer-request (same as your original)
        event_type   = "viewer-request"
        lambda_arn   = aws_lambda_function.sso_callback.qualified_arn
        include_body = false
      }
    }
  }

  # Default behavior – all other requests go through the SSO authenticator Lambda
  default_cache_behavior {
    target_origin_id       = "s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    dynamic "lambda_function_association" {
      for_each = var.enable_auth_flag ? [1] : []
      content {
        event_type   = "viewer-request"
        lambda_arn   = aws_lambda_function.sso_authenticator.qualified_arn
        include_body = false
      }
    }
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
