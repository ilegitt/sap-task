
# Defines the remote backend for storing Terraform's state file and required providers.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-state-bucket-unique-name" # <-- IMPORTANT: Change to your unique S3 bucket name
    key            = "applications/my-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock" # For state locking to prevent concurrent runs
    encrypt        = true
  }
}
