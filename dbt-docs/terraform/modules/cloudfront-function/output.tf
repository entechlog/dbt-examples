output "cloudfront_distribution__domain_name" {
  value = aws_cloudfront_distribution.app.domain_name
}

output "aws_s3_bucket__arn" {
  value = aws_s3_bucket.app.arn
}
