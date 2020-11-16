# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# variables for module/rds-postgres
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "ca_cert_identifier" { default = "rds-ca-2017" }
variable "name_prefix" {}

variable "engine" {}
variable "engine_version" {}
variable "instance_class" {}
variable "allocated_storage" {}

variable "database_name" {}
variable "db_username" {}
variable "db_password" {}
variable "db_port" {}
variable "multi_az" {}

variable "database_subnet_ids" { type = list(string)}

# security group
variable "vpc_id" {}
variable "private_subnets_cidr_blocks" { type = list(string)}
variable "mgmt_subnet_cidr_blocks" { type = list(string)}