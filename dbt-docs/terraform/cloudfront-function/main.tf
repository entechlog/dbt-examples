module "cloudfront_function" {
  source = "../modules/cloudfront-function"

  aws_region   = var.aws_region
  env_code     = var.env_code
  project_code = var.project_code
  app_code     = var.app_code
  use_env_code = var.use_env_code

  base64_user_pass = var.base64_user_pass

}