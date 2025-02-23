variable "env_code" {
  type        = string
  description = "Environmental code to identify the target environment"
  default     = "dev"
}

variable "project_code" {
  type        = string
  description = "Project code used as prefix for resource names"
  default     = "entechlog"
}

variable "app_code" {
  type        = string
  description = "Application code used as prefix for resource names"
  default     = "dbt-docs"
}

variable "aws_region" {
  type        = string
  description = "Primary region for AWS resources"
  default     = "us-east-1"
}

variable "use_env_code_flag" {
  type        = bool
  description = "Toggle on/off env code in resource names"
  default     = true
}

variable "enable_auth_flag" {
  type        = bool
  description = "Toggle on/off the SSO auth"
  default     = true
}

variable "lambda_runtime" {
  type        = string
  description = "Runtime for the Lambda functions"
  default     = "nodejs18.x" # e.g., nodejs18.x (14.x is deprecated)
}

variable "sso_config_arn" {
  type        = string
  description = "ARN of the AWS Secrets Manager secret containing SSO config"
}
