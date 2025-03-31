resource "aws_secretsmanager_secret" "dbt_sso_config" {
  name                    = "dbt-sso-secret"
  description             = "SSO config (tenant, client_id, client_secret, redirect_uri)"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "dbt_sso_config_version" {
  secret_id = aws_secretsmanager_secret.dbt_sso_config.id
  secret_string = jsonencode({
    tenant        = var.dbt_sso_tenant_id
    client_id     = var.dbt_sso_client_id
    client_secret = var.dbt_sso_client_secret
    redirect_uri  = var.dbt_sso_redirect_uri
  })
}

resource "aws_secretsmanager_secret" "elementary_sso_config" {
  name                    = "elementary-sso-secret"
  description             = "SSO config (tenant, client_id, client_secret, redirect_uri)"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "elementary_sso_config_version" {
  secret_id = aws_secretsmanager_secret.elementary_sso_config.id
  secret_string = jsonencode({
    tenant        = var.dbt_sso_tenant_id
    client_id     = var.dbt_sso_client_id
    client_secret = var.dbt_sso_client_secret
    redirect_uri  = var.elementary_sso_redirect_uri
  })
}
