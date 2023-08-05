output "cloudfront_distribution__domain_name" {
  value = module.cloudfront_function.cloudfront_distribution__domain_name
}

output "aws_s3_bucket__arn" {
  value = module.cloudfront_function.aws_s3_bucket__arn
}