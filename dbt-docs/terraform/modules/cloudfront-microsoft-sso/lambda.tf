locals {
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

  # Create minimal lambda handlers to ensure the archives are never empty
  minimal_authenticator_code = <<-EOT
    exports.handler = async (event) => {
      console.log('Authenticator handler called');
      return {
        statusCode: 500,
        body: JSON.stringify({ message: "Default handler - not properly configured" })
      };
    };
  EOT

  minimal_callback_code = <<-EOT
    exports.handler = async (event) => {
      console.log('Callback handler called');
      return {
        statusCode: 500,
        body: JSON.stringify({ message: "Default handler - not properly configured" })
      };
    };
  EOT
}

# Directly create the authenticator.js file to ensure it exists
resource "local_file" "authenticator_js" {
  filename = "${local.temp_authenticator_dir}/authenticator.js"
  content  = local.minimal_authenticator_code
  
  # Create the directory if it doesn't exist
  provisioner "local-exec" {
    command = "mkdir -p ${dirname(self.filename)}"
  }
}

# Directly create the callback-handler.js file to ensure it exists
resource "local_file" "callback_handler_js" {
  filename = "${local.temp_callback_dir}/callback-handler.js"
  content  = local.minimal_callback_code
  
  # Create the directory if it doesn't exist
  provisioner "local-exec" {
    command = "mkdir -p ${dirname(self.filename)}"
  }
}

# Prepare authenticator code in temporary directory
resource "null_resource" "prepare_authenticator" {
  triggers = {
    authenticator_dir     = local.sso_authenticator_dir
    authenticator_dir_sha = local.sso_authenticator_sha
    secret_name           = local.secret_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Preparing authenticator files..."
      
      # Check if source directory exists and has files
      if [ -d "${local.sso_authenticator_dir}" ] && [ "$(ls -A ${local.sso_authenticator_dir})" ]; then
        echo "Copying from ${local.sso_authenticator_dir}"
        cp -f ${local.sso_authenticator_dir}/*.js ${local.temp_authenticator_dir}/ 2>/dev/null || true
        cp -f ${local.sso_authenticator_dir}/*.json ${local.temp_authenticator_dir}/ 2>/dev/null || true
        
        # If authenticator.js exists, update the SECRET_NAME
        if [ -f "${local.temp_authenticator_dir}/authenticator.js" ]; then
          sed -i 's/const SECRET_NAME = "SECRET-NAME-PLACEHOLDER";/const SECRET_NAME = "${local.secret_name}";/g' ${local.temp_authenticator_dir}/authenticator.js
          echo "Updated SECRET_NAME in authenticator.js"
        fi
      else
        echo "WARNING: Source directory ${local.sso_authenticator_dir} does not exist or is empty"
      fi
      
      # Verify files were copied
      echo "Files in destination directory:"
      ls -la ${local.temp_authenticator_dir}/
    EOT
  }

  depends_on = [local_file.authenticator_js]
}

# Prepare callback code in temporary directory
resource "null_resource" "prepare_callback" {
  triggers = {
    callback_dir     = local.sso_callback_dir
    callback_dir_sha = local.sso_callback_sha
    secret_name      = local.secret_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Preparing callback files..."
      
      # Check if source directory exists and has files
      if [ -d "${local.sso_callback_dir}" ] && [ "$(ls -A ${local.sso_callback_dir})" ]; then
        echo "Copying from ${local.sso_callback_dir}"
        cp -f ${local.sso_callback_dir}/*.js ${local.temp_callback_dir}/ 2>/dev/null || true
        cp -f ${local.sso_callback_dir}/*.json ${local.temp_callback_dir}/ 2>/dev/null || true
        
        # If callback-handler.js exists, update the SECRET_NAME
        if [ -f "${local.temp_callback_dir}/callback-handler.js" ]; then
          sed -i 's/const SECRET_NAME = "SECRET-NAME-PLACEHOLDER";/const SECRET_NAME = "${local.secret_name}";/g' ${local.temp_callback_dir}/callback-handler.js
          echo "Updated SECRET_NAME in callback-handler.js"
        fi
      else
        echo "WARNING: Source directory ${local.sso_callback_dir} does not exist or is empty"
      fi
      
      # Verify files were copied
      echo "Files in destination directory:"
      ls -la ${local.temp_callback_dir}/
    EOT
  }

  depends_on = [local_file.callback_handler_js]
}

# Ensure tmp/artifacts directory exists
resource "null_resource" "ensure_artifacts_dir" {
  provisioner "local-exec" {
    command = "mkdir -p tmp/artifacts"
  }
}

data "archive_file" "sso_authenticator" {
  type             = "zip"
  source_dir       = local.temp_authenticator_dir
  output_path      = "tmp/artifacts/${local.instance_id}-authenticator.zip"
  output_file_mode = "0666"

  depends_on = [
    local_file.authenticator_js,
    null_resource.prepare_authenticator,
    null_resource.ensure_artifacts_dir
  ]
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

data "archive_file" "sso_callback" {
  type             = "zip"
  source_dir       = local.temp_callback_dir
  output_path      = "tmp/artifacts/${local.instance_id}-callback.zip"
  output_file_mode = "0666"

  depends_on = [
    local_file.callback_handler_js,
    null_resource.prepare_callback,
    null_resource.ensure_artifacts_dir
  ]
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