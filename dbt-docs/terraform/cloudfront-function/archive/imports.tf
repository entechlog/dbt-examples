# Imports are done by running the command
# terraform plan -generate-config-out=generated_resources.tf

import {
  # ID of the cloud resource
  # Check provider documentation for importable resources and format
  id = "us-east-1_3RfZKERfJ"
  # Resource address
  to = aws_cognito_user_pool.dbt_docs
}

import {
  # ID of the cloud resource
  # Check provider documentation for importable resources and format
  id = "us-east-1_3RfZKERfJ/4s4ctfvho0o1eh4vet33r013ki"
  # Resource address
  to = aws_cognito_user_pool_client.dbt_docs
}