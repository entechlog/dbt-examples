# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "app" {
  comment = "${var.app_code} CloudFront origin access identity"
}

# CloudFront Distribution
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

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    #trusted_signers        = ["self"]
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

  ordered_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    path_pattern           = "*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    dynamic "function_association" {
      for_each = var.enable_auth_flag == true ? toset([1]) : toset([])
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.app[0].arn
      }
    }
  }
}

resource "aws_cloudfront_function" "app" {

  count = "${var.enable_auth_flag}" == true ? 1 : 0

  name    = "BasicAuthFn"
  comment = "Add HTTP Basic authentication to CloudFront"
  runtime = "cloudfront-js-1.0"
  publish = true

  code = <<EOF
  function handler(event) {
    var authHeaders = event.request.headers.authorization;
    var expected = 'Basic ${var.base64_user_pass}';

    if (authHeaders && authHeaders.value === expected) {
      return event.request;
    }

    var response = {
      statusCode: 401,
      statusDescription: 'Unauthorized',
      headers: {
        'www-authenticate': {
          value: 'Basic realm="Enter login details"',
        },
      },
    };

    return response;
  }
  EOF
}
