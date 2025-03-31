locals {
  # Track code changes in .js/.json
  sso_authenticator_files = fileset(local.sso_authenticator_dir, "*.{js,json}")
  sso_authenticator_sha = sha256(join(",", [
    for file in local.sso_authenticator_files : filesha256("${local.sso_authenticator_dir}/${file}")
  ]))

  sso_callback_files = fileset(local.sso_callback_dir, "*.{js,json}")
  sso_callback_sha = sha256(join(",", [
    for file in local.sso_callback_files : filesha256("${local.sso_callback_dir}/${file}")
  ]))

  # Extract the secret name from the ARN
  # ARN format: arn:aws:secretsmanager:region:account:secret:name-suffix
  # First get the last part of the ARN
  full_secret_part = element(split(":", var.sso_config_arn), length(split(":", var.sso_config_arn)) - 1)

  # Then extract just the base name (everything before the last hyphen and random characters)
  secret_name = join("-", slice(split("-", local.full_secret_part), 0, length(split("-", local.full_secret_part)) - 1))
}

# Track changes to trigger rebuilds only when necessary
resource "null_resource" "prepare_triggers" {
  triggers = {
    authenticator_dir_sha = local.sso_authenticator_sha
    callback_dir_sha      = local.sso_callback_sha
    secret_name           = local.secret_name
  }
}

# Prepare authenticator code in temporary directory
resource "null_resource" "prepare_authenticator" {
#  depends_on = [null_resource.prepare_triggers]

  # Use single-line command to avoid line ending issues
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "mkdir -p ${local.temp_authenticator_dir} && cp -r ${local.sso_authenticator_dir}/* ${local.temp_authenticator_dir}/ && sed -i 's/const SECRET_NAME = \"SECRET-NAME-PLACEHOLDER\";/const SECRET_NAME = \"${local.secret_name}\";/g' ${local.temp_authenticator_dir}/authenticator.js"
  }
}

# Prepare callback code in temporary directory
resource "null_resource" "prepare_callback" {
#  depends_on = [null_resource.prepare_triggers]

  # Use single-line command to avoid line ending issues
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "mkdir -p ${local.temp_callback_dir} && cp -r ${local.sso_callback_dir}/* ${local.temp_callback_dir}/ && sed -i 's/const SECRET_NAME = \"SECRET-NAME-PLACEHOLDER\";/const SECRET_NAME = \"${local.secret_name}\";/g' ${local.temp_callback_dir}/callback-handler.js"
  }
}

###############################
# Package & deploy SSO Authenticator
###############################

data "archive_file" "sso_authenticator" {
  type             = "zip"
  source_dir       = "${local.temp_authenticator_dir}"
  output_path      = "${local.temp_authenticator_dir}/payload.zip"
  excludes         = ["payload.zip"]
  output_file_mode = "0666"

  depends_on = [null_resource.prepare_triggers, null_resource.prepare_authenticator]
}

resource "aws_lambda_function" "sso_authenticator" {
  function_name    = "${lower(var.name_prefix)}-${lower(var.app_code)}-sso-authenticator"
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

data "archive_file" "sso_callback" {
  type             = "zip"
  source_dir       = "${local.temp_callback_dir}"
  output_path      = "${local.temp_callback_dir}/payload.zip"
  excludes         = ["payload.zip"]
  output_file_mode = "0666"

  depends_on = [null_resource.prepare_triggers, null_resource.prepare_callback]
}

resource "aws_lambda_function" "sso_callback" {
  function_name    = "${lower(var.name_prefix)}-${lower(var.app_code)}-sso-callback"
  role             = aws_iam_role.lambda_edge.arn
  filename         = data.archive_file.sso_callback.output_path
  runtime          = var.lambda_runtime
  handler          = "callback-handler.handler"
  source_code_hash = data.archive_file.sso_callback.output_base64sha256
  publish          = true
}