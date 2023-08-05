module "cloudfront_cognito" {
  source = "../modules/cloudfront-cognito"

  aws_region        = var.aws_region
  env_code          = var.env_code
  project_code      = var.project_code
  app_code          = var.app_code
  use_env_code_flag = var.use_env_code_flag

  aws_cloudfront_distribution__domain_name = var.aws_cloudfront_distribution__domain_name

}