output "dbt__cloudfront_distribution__domain_name" {
  value = module.sso_auth.cloudfront_distribution__domain_name
}

output "dbt__aws_s3_bucket__arn" {
  value = module.sso_auth.aws_s3_bucket__arn
}

output "dbt__secret_arn" {
  description = "The ARN of the SSO secret"
  value       = aws_secretsmanager_secret.sso_config.arn
}