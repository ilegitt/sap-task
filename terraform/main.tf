# This is the core Terraform file that defines the AWS RDS database instance
 and the corresponding secret in AWS Secrets Manager.

provider "aws" {
  region = var.aws_region
}

# Resource to generate a random, secure password for the database.

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Resource to create a secret in AWS Secrets Manager.

resource "aws_secretsmanager_secret" "db_secret" {
  name        = "/${var.environment}/app/db-credentials"
  description = "Database credentials for my-application in ${var.environment}"
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Resource to store the generated password and username as a JSON object in the secret.

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
  })
}

# The main RDS instance resource.

resource "aws_db_instance" "app_database" {
  engine               = "postgres"
  engine_version       = "14.5"
  identifier           = "app-db-${var.environment}"
  db_name              = var.db_name
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage

  # The password is now taken from the random_password resource.
  username             = var.db_username
  password             = random_password.db_password.result

  # Networking 
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_id]

  # Backup and Maintenance
  backup_retention_period = 7
  multi_az                = var.environment == "prod"
  
  # Deletion Protection
  deletion_protection = var.environment == "prod"
  skip_final_snapshot = var.environment != "prod"

  tags = {
    Name        = "app-db-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Ensure the secret is created before the database instance.

  depends_on = [
    aws_secretsmanager_secret_version.db_secret_version
  ]
}
