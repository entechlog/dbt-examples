# main.tf
module "sso_auth" {
  source = "../modules/cloudfront-microsoft-sso"

  env_code          = var.env_code
  project_code      = var.project_code
  app_code          = var.app_code
  aws_region        = var.aws_region
  use_env_code_flag = var.use_env_code_flag
  enable_auth_flag  = var.enable_auth_flag

  lambda_runtime = var.lambda_runtime
  sso_config_arn = aws_secretsmanager_secret.sso_config.arn
}
