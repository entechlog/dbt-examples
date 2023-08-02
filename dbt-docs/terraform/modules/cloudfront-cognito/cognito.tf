# AWS Cognito User Pool
resource "aws_cognito_user_pool" "app" {
  name = "${local.resource_name_prefix}-cognito-user-pool"

  alias_attributes           = null
  auto_verified_attributes   = ["email"]
  deletion_protection        = "INACTIVE"
  email_verification_message = null
  email_verification_subject = null
  mfa_configuration          = "OPTIONAL"
  sms_authentication_message = null
  sms_verification_message   = null
  tags                       = {}
  tags_all                   = {}
  username_attributes        = ["email"]
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  email_configuration {
    configuration_set      = null
    email_sending_account  = "COGNITO_DEFAULT"
    from_email_address     = null
    reply_to_email_address = null
    source_arn             = null
  }
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "family_name"
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "given_name"
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  software_token_mfa_configuration {
    enabled = true
  }
  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }
  username_configuration {
    case_sensitive = false
  }
  verification_message_template {
    default_email_option  = "CONFIRM_WITH_CODE"
    email_message         = null
    email_message_by_link = null
    email_subject         = null
    email_subject_by_link = null
    sms_message           = null
  }
  lambda_config {
    pre_sign_up = aws_lambda_function.cognito_pre_sign_up.arn
  }
}

# AWS Cognito User Pool Client
resource "aws_cognito_user_pool_client" "app" {
  name         = "${local.resource_name_prefix}-cognito-user-pool-client"
  user_pool_id = aws_cognito_user_pool.app.id

  access_token_validity                         = 60
  allowed_oauth_flows                           = ["code"]
  allowed_oauth_flows_user_pool_client          = true
  allowed_oauth_scopes                          = ["email", "openid", "phone"]
  auth_session_validity                         = 3
  callback_urls                                 = ["https://${local.aws_cloudfront_distribution__domain_name}"]
  default_redirect_uri                          = null
  enable_propagate_additional_user_context_data = false
  enable_token_revocation                       = true
  explicit_auth_flows                           = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
  generate_secret                               = null
  id_token_validity                             = 60
  logout_urls                                   = []
  prevent_user_existence_errors                 = "ENABLED"
  read_attributes                               = ["address", "birthdate", "email", "email_verified", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "phone_number_verified", "picture", "preferred_username", "profile", "updated_at", "website", "zoneinfo"]
  refresh_token_validity                        = 30
  supported_identity_providers                  = ["COGNITO"]
  write_attributes                              = ["address", "birthdate", "email", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "picture", "preferred_username", "profile", "updated_at", "website", "zoneinfo"]
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

# AWS Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "app" {
  domain       = local.resource_name_prefix
  user_pool_id = aws_cognito_user_pool.app.id
}

# AWS Cognito Identity Pool
resource "aws_cognito_identity_pool" "app" {
  identity_pool_name               = "${local.resource_name_prefix}-cognito-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.app.id
    provider_name           = aws_cognito_user_pool.app.endpoint
    server_side_token_check = false
  }
}

