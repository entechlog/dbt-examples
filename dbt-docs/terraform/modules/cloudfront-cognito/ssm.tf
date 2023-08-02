locals {
  lambda_configuration = {
    region         = data.aws_region.current.name
    userPoolId     = aws_cognito_user_pool.app.id
    userPoolAppId  = "${aws_cognito_user_pool_client.app.id}"
    userPoolDomain = "${aws_cognito_user_pool_domain.app.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"

    userPoolAppSecret    = var.cognito_user_pool_app_client_secret == null ? "" : var.cognito_user_pool_app_client_secret
    cookieExpirationDays = var.cognito_cookie_expiration_days
    disableCookieDomain  = var.cognito_disable_cookie_domain
    logLevel             = var.cognito_log_level
  }
}

resource "aws_kms_key" "ssm_kms_key" {
  description             = "KMS Encryption key for lambda-edge auth"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_ssm_parameter" "lambda_configuration_parameters" {
  name        = "/lambda/edge/configuration"
  description = "Lambda@Edge Configuration for Application"
  type        = "SecureString"
  key_id      = aws_kms_key.ssm_kms_key.key_id
  value       = jsonencode(local.lambda_configuration)
}