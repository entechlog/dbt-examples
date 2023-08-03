locals {
  cognito_authenticator_files = fileset("../uploads/lambda/cognito_authenticator/", "*.{js,json}")
  cognito_authenticator_sha   = sha256(join(",", [for file in local.cognito_authenticator_files : filesha256("../uploads/lambda/cognito_authenticator/${file}")]))
}

resource "null_resource" "cognito_authenticator" {
  provisioner "local-exec" {
    command     = "npm ci --production"
    working_dir = abspath("../uploads/lambda/cognito_authenticator")
  }

  triggers = {
    deployable_dir = local.cognito_authenticator_sha
  }

}

data "archive_file" "cognito_authenticator" {
  depends_on = [null_resource.cognito_authenticator]

  type             = "zip"
  source_dir       = "../uploads/lambda/cognito_authenticator"
  output_path      = "../uploads/lambda/cognito_authenticator/payload.zip"
  excludes         = ["payload.zip"]
  output_file_mode = "0666"
}

resource "aws_lambda_function" "cognito_authenticator" {
  function_name = "${lower(var.project_code)}-cognito-auth-function"
  role          = aws_iam_role.lambda_cognito_auth.arn
  filename      = data.archive_file.cognito_authenticator.output_path
  runtime       = "nodejs14.x"
  handler       = "index.handler"

  publish = true
}

data "archive_file" "cognito_pre_sign_up" {

  type             = "zip"
  source_dir       = "../uploads/lambda/cognito_pre_sign_up"
  output_path      = "../uploads/lambda/cognito_pre_sign_up/payload.zip"
  excludes         = ["payload.zip"]
  output_file_mode = "0666"
}

resource "aws_lambda_function" "cognito_pre_sign_up" {
  function_name = "${lower(var.project_code)}-cognito-pre-signup-function"
  role          = aws_iam_role.lambda_cognito_pre_sign_up.arn
  filename      = data.archive_file.cognito_pre_sign_up.output_path
  runtime       = "nodejs14.x"
  handler       = "index.handler"

  publish = true
}

resource "aws_lambda_permission" "cognito_pre_sign_up" {
  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cognito_pre_sign_up.arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.app.arn
}
