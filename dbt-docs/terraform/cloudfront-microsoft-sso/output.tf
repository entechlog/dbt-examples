output "dbt__cloudfront_distribution__domain_name" {
  value = module.dbt_sso_auth.cloudfront_distribution__domain_name
}

output "dbt__aws_s3_bucket__arn" {
  value = module.dbt_sso_auth.aws_s3_bucket__arn
}

output "dbt__secret_arn" {
  description = "The ARN of the SSO secret"
  value       = aws_secretsmanager_secret.dbt_sso_config.arn
}

output "elementary__cloudfront_distribution__domain_name" {
  value = module.elementary_sso_auth.cloudfront_distribution__domain_name
}

output "elementary__aws_s3_bucket__arn" {
  value = module.elementary_sso_auth.aws_s3_bucket__arn
}

output "elementary__secret_arn" {
  description = "The ARN of the SSO secret"
  value       = aws_secretsmanager_secret.elementary_sso_config.arn
}