resource "aws_secretsmanager_secret" "sso_config" {
  name                    = "dbt-sso-secret"
  description             = "SSO config (tenant, client_id, client_secret, redirect_uri)"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "sso_config_version" {
  secret_id = aws_secretsmanager_secret.sso_config.id
  secret_string = jsonencode({
    tenant        = var.sso_tenant_id
    client_id     = var.sso_client_id
    client_secret = var.sso_client_secret
    redirect_uri  = var.sso_redirect_uri
  })
}
