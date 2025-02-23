###############################
# Data blocks: IAM policy docs
###############################

# 1) Trust policy for Lambda@Edge
data "aws_iam_policy_document" "lambda_edge_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}

# 2) Secrets access policy if your Lambda needs to read from Secrets Manager
data "aws_iam_policy_document" "lambda_edge_secrets_access" {
  statement {
    effect = "Allow"
    actions = [
      # Secrets Manager
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      # CloudWatch Logs
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      # KMS
      "kms:Decrypt"
    ]
    resources = [
      # Secrets in the same account/region
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",

      # CloudWatch log groups for Lambda
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",

      # KMS keys in the same account/region
      "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }
}

###############################
# IAM Role for Lambda@Edge
###############################

resource "aws_iam_role" "lambda_edge" {
  name               = "${local.resource_name_prefix}-lambda-edge-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_edge_assume_role.json
}

###############################
# Attach Logging Policy
###############################

resource "aws_iam_role_policy_attachment" "lambda_edge_logs" {
  role       = aws_iam_role.lambda_edge.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

###############################
# Attach Secrets Access Policy
###############################

resource "aws_iam_role_policy" "lambda_edge_secrets_access" {
  name   = "${local.resource_name_prefix}-edge-secrets-policy"
  role   = aws_iam_role.lambda_edge.id
  policy = data.aws_iam_policy_document.lambda_edge_secrets_access.json
}