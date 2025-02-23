variable "env_code" {
  type        = string
  description = "Environmental code to identify the target environment"
  default     = "dev"
}

variable "project_code" {
  type        = string
  description = "Project code used as a prefix for resource names"
  default     = "entechlog"
}

variable "app_code" {
  type        = string
  description = "Application code used as a prefix for resource names"
  default     = "dbt-docs"
}

variable "aws_region" {
  type        = string
  description = "Primary region for all AWS resources"
  default     = "us-east-1"
}

variable "use_env_code_flag" {
  type        = bool
  description = "Toggle on/off the env code in resource names"
  default     = true
}

variable "enable_auth_flag" {
  type        = bool
  description = "Toggle on/off the SSO authentication"
  default     = true
}

# -- SSO details: you will store these in Secrets Manager outside the module
variable "sso_tenant_id" {
  type        = string
  description = "Tenant ID for the SSO config"
}

variable "sso_client_id" {
  type        = string
  description = "Client ID for the SSO config"
}

variable "sso_client_secret" {
  type        = string
  description = "Client Secret for the SSO config"
  sensitive   = true
}

variable "sso_redirect_uri" {
  type        = string
  description = "Redirect URI for the SSO flow"
}

# Optional override for Node.js runtime (the module defaults to nodejs18.x if not specified)
variable "lambda_runtime" {
  type        = string
  description = "Runtime for the Lambda functions"
  default     = "nodejs18.x"
}
