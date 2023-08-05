locals {
  account_id           = data.aws_caller_identity.current.account_id
  resource_name_prefix = var.use_env_code_flag == true ? "${lower(var.env_code)}-${lower(var.project_code)}-${lower(var.app_code)}" : "${lower(var.project_code)}-${lower(var.app_code)}"

  aws_cloudfront_distribution__domain_name = var.aws_cloudfront_distribution__domain_name == null ? "example.com/signin" : var.aws_cloudfront_distribution__domain_name

  # file extensions to mime types mapping
  mime_type_mappings = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".ico"  = "image/vnd.microsoft.icon"
    ".jpeg" = "image/jpeg"
    ".png"  = "image/png"
    ".svg"  = "image/svg+xml"
  }

}
