# Defines the values that will be output after Terraform applies the configuration.

output "db_endpoint" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.app_database.endpoint
}

output "db_username" {
  description = "The username for the database."
  value       = aws_db_instance.app_database.username
}

# Instead of the password, we output the ARN of the secret.

output "db_secret_arn" {
  description = "The ARN of the AWS Secrets Manager secret containing the DB credentials."
  value       = aws_secretsmanager_secret.db_secret.arn
}
