# main.tf
module "sso_auth" {
  source = "../modules/cloudfront-microsoft-sso"

  name_prefix      = local.resource_name_prefix
  app_code         = "dbt-docs"
  enable_auth_flag = true

  lambda_runtime = "nodejs18.x"
  sso_config_arn = aws_secretsmanager_secret.sso_config.arn
}