// Output the AWS region where the resources are created
output "aws_region" {
  value = data.aws_region.current.name
}

// Output the ID of the Cognito User Pool for app
output "cognito_user_pool__id" {
  value = aws_cognito_user_pool.app.id
}

// Output the ID of the Cognito User Pool Client for app
output "cognito_user_pool_client__id" {
  value = aws_cognito_user_pool_client.app.id
}

// Output the ID of the CloudFront distribution for the app distribution
output "cloudfront_distribution__id" {
  value = aws_cloudfront_distribution.app.id
}

// Output the domain name of the CloudFront distribution for the app distribution
output "cloudfront_distribution__domain_name" {
  value = aws_cloudfront_distribution.app.domain_name
}

output "aws_s3_bucket__arn" {
  value = aws_s3_bucket.app.arn
}
