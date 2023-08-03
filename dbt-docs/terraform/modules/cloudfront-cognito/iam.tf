data "aws_iam_policy_document" "lambda_cognito_auth" {
  statement {
    sid    = "AllowAwsToAssumeRole"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda_cognito_pre_sign_up" {
  statement {
    sid    = "AllowAwsToAssumeRole"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "lambda_cognito_auth" {
  name = "${local.resource_name_prefix}-lambda-cognito-auth-role"

  assume_role_policy = data.aws_iam_policy_document.lambda_cognito_auth.json

  inline_policy {
    name = "cloudwatch_logs_create"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  inline_policy {
    name = "lambda_edge_self_role_read"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["iam:GetRolePolicy"]
          Effect   = "Allow"
          Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.resource_name_prefix}-lambda-cognito-auth-role"
        },
        {
          Action   = ["sts:GetCallerIdentity"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name = "ssm_parameter_read"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["ssm:GetParameter"]
          Effect   = "Allow"
          Resource = aws_ssm_parameter.lambda_configuration_parameters.arn
        },
      ]
    })
  }

  inline_policy {
    name = "ssm_parameter_decrypt"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["kms:Decrypt"]
          Effect   = "Allow"
          Resource = aws_kms_key.ssm_kms_key.arn
        },
      ]
    })
  }
}

resource "aws_iam_role" "lambda_cognito_pre_sign_up" {
  name = "${local.resource_name_prefix}-lambda-cognito-pre-sign-up-role"

  assume_role_policy = data.aws_iam_policy_document.lambda_cognito_pre_sign_up.json

  inline_policy {
    name = "cloudwatch_logs_create"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  inline_policy {
    name = "lambda_edge_self_role_read"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["iam:GetRolePolicy"]
          Effect   = "Allow"
          Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.resource_name_prefix}-lambda-cognito-pre-sign-up-role"
        },
        {
          Action   = ["sts:GetCallerIdentity"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

}