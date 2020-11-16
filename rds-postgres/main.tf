# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/rds-postgres
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.25.1 and above) recommends Terraform 0.13.3 or above.
  required_version = ">= 0.13.3"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.5.0"
    }
  }
}
####################################
# security group for Agency Postgres
####################################
resource "aws_security_group" "sg" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow ssh from bastion and private subnets and TLS over 5432"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC private subnets"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnets_cidr_blocks
  }
  ingress {
    description = "TLS from Bastions"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.mgmt_subnet_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-rds-sg"
  }
}

###########
# Master DB
###########
module "master" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.20.0"

  ca_cert_identifier = var.ca_cert_identifier

  identifier = "${var.name_prefix}-master-postgres"

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  name     = var.database_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port
  multi_az = var.multi_az

  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_ids             = var.database_subnet_ids

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Backups are required in order to create a replica
  backup_retention_period = 7

  create_db_option_group    = false
  create_db_parameter_group = false
}
############
# Replica DB
############
module "replica" {
  source             = "terraform-aws-modules/rds/aws"
  ca_cert_identifier = "rds-ca-2017"

  identifier = "${var.name_prefix}-replica-postgres"

  # Source database. For cross-region use this_db_instance_arn
  replicate_source_db = module.master.this_db_instance_id

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  # Username and password must not be set for replicas
  username = ""
  password = ""
  port     = var.db_port

  vpc_security_group_ids = [aws_security_group.sg.id]

  maintenance_window = "Tue:00:00-Tue:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  # Not allowed to specify a subnet group for replicas in the same region
  create_db_subnet_group = false

  create_db_option_group    = false
  create_db_parameter_group = false
}
