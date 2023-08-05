## ---------------------------------------------------------------------------------------------------------------------
## ENVIRONMENT VARIABLES
## Define these secrets as environment variables
## Example : TF_VAR_master_password
## ---------------------------------------------------------------------------------------------------------------------

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : optional_var
## ---------------------------------------------------------------------------------------------------------------------

variable "env_code" {
  type        = string
  description = "Environmental code to identify the target environment"
  default     = "dev"
}

variable "project_code" {
  type        = string
  description = "Project code which will be used as prefix when naming resources"
  default     = "entechlog"
}

variable "app_code" {
  type        = string
  description = "Application code which will be used as prefix when naming resources"
  default     = "dbt-docs"
}

variable "aws_region" {
  type        = string
  description = "Primary region for all AWS resources"
  default     = "us-east-1"
}

# boolean variable
variable "use_env_code_flag" {
  type        = bool
  description = "toggle on/off the env code in the resource names"
  default     = true
}

variable "aws_cloudfront_distribution__domain_name" {
  type        = string
  description = "Cloudfront distribution domain_name"
  default     = null
}

variable "cognito_user_pool_app_client_secret" {
  description = "Cognito User Pool App Client Secret for the targeted user pool. NOTE: This is currently not compatible with AppSync applications."
  type        = string
  default     = null
}

variable "cognito_cookie_expiration_days" {
  description = "Number of days to keep the cognito cookie valid."
  type        = number
  default     = 7
}

variable "cognito_disable_cookie_domain" {
  description = "Sets domain attribute in cookies, defaults to false."
  type        = bool
  default     = false
}

variable "cognito_log_level" {
  description = "Logging level. Default: 'silent'"
  type        = string
  default     = "silent"

  validation {
    condition     = contains(["fatal", "error", "warn", "info", "debug", "trace", "silent"], var.cognito_log_level)
    error_message = "Cognito Log Level must be one of: ['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent']."
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : required_var
## ---------------------------------------------------------------------------------------------------------------------
