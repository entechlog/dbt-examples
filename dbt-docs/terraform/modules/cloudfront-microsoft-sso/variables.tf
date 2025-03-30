variable "name_prefix" {
  type        = string
  description = "Resource name prefix"
}

variable "app_code" {
  type        = string
  description = "Application code used as prefix for resource names"
  default     = "dbt-docs"
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
