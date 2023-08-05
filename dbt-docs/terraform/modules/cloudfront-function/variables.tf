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

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : required_var
## ---------------------------------------------------------------------------------------------------------------------

variable "enable_auth_flag" {
  type        = bool
  description = "Toggle on/off the HTTP Basic Auth"
  default     = false
}

variable "base64_user_pass" {
  description = "Base64 encoded username and password for HTTP Basic Auth"
  type        = string
  default     = "dGVzdDp0ZXN0"
}