# dbt docs
module "dbt_sso_auth" {
  source = "../modules/cloudfront-microsoft-sso"

  name_prefix      = local.resource_name_prefix
  app_code         = "dbt-docs"
  enable_auth_flag = true

  lambda_runtime = "nodejs18.x"
  sso_config_arn = aws_secretsmanager_secret.dbt_sso_config.arn
}

# elementary data
module "elementary_sso_auth" {
  source = "../modules/cloudfront-microsoft-sso"

  name_prefix      = local.resource_name_prefix
  app_code         = "elementary-data"
  enable_auth_flag = true

  lambda_runtime = "nodejs18.x"
  sso_config_arn = aws_secretsmanager_secret.elementary_sso_config.arn
}