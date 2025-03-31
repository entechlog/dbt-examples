locals {
  account_id = data.aws_caller_identity.current.account_id

  # Hard-coded directories for Lambda code
  sso_authenticator_dir = "../uploads/lambda/sso_authenticator"
  sso_callback_dir      = "../uploads/lambda/sso_callback"

  # Create unique temporary directories for each module instance
  instance_id            = sha256("${var.name_prefix}-${var.app_code}")
  temp_authenticator_dir = "${path.module}/temp/lambda/${local.instance_id}/authenticator"
  temp_callback_dir      = "${path.module}/temp/lambda/${local.instance_id}/callback"

  # file extensions to mime types mapping
  mime_type_mappings = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".ico"  = "image/vnd.microsoft.icon"
    ".jpeg" = "image/jpeg"
    ".png"  = "image/png"
    ".svg"  = "image/svg+xml"
  }

}
