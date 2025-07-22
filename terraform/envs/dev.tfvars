# Environment-specific variables for 'development'. The password is no longer here.

environment              = "dev"
db_instance_class        = "db.t3.micro"
db_allocated_storage     = 20
db_max_allocated_storage = 50
db_name                  = "myapplication_dev"
db_username              = "devuser"
db_subnet_group_name     = "my-private-db-subnet-group"    # Replace with your existing subnet group
db_security_group_id     = "sg-012345abcdef"               # Replace with your existing security group ID
