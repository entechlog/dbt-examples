locals {
  # If you want to track code changes in .js/.json:
  sso_authenticator_files = fileset(local.sso_authenticator_dir, "*.{js,json}")
  sso_authenticator_sha   = sha256(join(",", [
    for file in local.sso_authenticator_files : filesha256("${local.sso_authenticator_dir}/${file}")
  ]))

  sso_callback_files = fileset(local.sso_callback_dir, "*.{js,json}")
  sso_callback_sha   = sha256(join(",", [
    for file in local.sso_callback_files : filesha256("${local.sso_callback_dir}/${file}")
  ]))
}

###############################
# Package & deploy SSO Authenticator
###############################

resource "null_resource" "sso_authenticator" {
  # No local-exec block here anymore
  triggers = {
    deployable_dir = local.sso_authenticator_sha
  }
}

data "archive_file" "sso_authenticator" {
  depends_on       = [null_resource.sso_authenticator]
  type             = "zip"
  source_dir       = local.sso_authenticator_dir
  output_path      = "${local.sso_authenticator_dir}/payload.zip"
  excludes         = ["payload.zip"]
  output_file_mode = "0666"
}

resource "aws_lambda_function" "sso_authenticator" {
  function_name    = "${lower(var.project_code)}-sso-authenticator"
  role             = aws_iam_role.lambda_edge.arn
  filename         = data.archive_file.sso_authenticator.output_path
  runtime          = var.lambda_runtime
  handler          = "authenticator.handler"
  source_code_hash = data.archive_file.sso_authenticator.output_base64sha256
  publish          = true
}

###############################
# Package & deploy SSO Callback
###############################

resource "null_resource" "sso_callback" {
  # No local-exec block here anymore
  triggers = {
    deployable_dir = local.sso_callback_sha
  }
}

data "archive_file" "sso_callback" {
  depends_on       = [null_resource.sso_callback]
  type             = "zip"
  source_dir       = local.sso_callback_dir
  output_path      = "${local.sso_callback_dir}/payload.zip"
  excludes         = ["payload.zip"]
  output_file_mode = "0666"
}

resource "aws_lambda_function" "sso_callback" {
  function_name    = "${lower(var.project_code)}-sso-callback"
  role             = aws_iam_role.lambda_edge.arn
  filename         = data.archive_file.sso_callback.output_path
  runtime          = var.lambda_runtime
  handler          = "callback-handler.handler"
  source_code_hash = data.archive_file.sso_callback.output_base64sha256
  publish          = true
}
