# Environment-specific variables for 'production'.

environment              = "prod"
db_instance_class        = "db.m5.large"
db_allocated_storage     = 100
db_max_allocated_storage = 500
db_name                  = "myapplication_prod"
db_username              = "produser"
db_subnet_group_name     = "my-private-db-subnet-group-prod"     # Replace with your existing PROD subnet group
db_security_group_id     = "sg-fedcba543210"                     # Replace with your existing PROD security group ID
