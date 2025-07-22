# Declares all the variables used in the Terraform configuration.
 The db_password variable has been removed for security.

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
}

variable "db_instance_class" {
  description = "The instance class for the RDS database."
  type        = string
}

variable "db_allocated_storage" {
  description = "The initial allocated storage for the database in GB."
  type        = number
}

variable "db_max_allocated_storage" {
  description = "The maximum storage to allow for autoscaling in GB."
  type        = number
}

variable "db_name" {
  description = "The name of the database to create."
  type        = string
}

variable "db_username" {
  description = "The master username for the database."
  type        = string
}

variable "db_subnet_group_name" {
  description = "The name of the existing DB subnet group in your VPC."
  type        = string
}

variable "db_security_group_id" {
  description = "The ID of the existing security group to associate with the database."
  type        = string
}
