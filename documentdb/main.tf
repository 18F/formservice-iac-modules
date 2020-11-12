# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/documentdb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.25.1 and above) recommends Terraform 0.13.3 or above.
  required_version = ">= 0.13.3"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = ">= 3.5.0"
    }
  }
}

module "documentdb_cluster" {
  source  = "cloudposse/documentdb-cluster/aws"
  version = "0.6.0"
  # insert the 3 required variables here
  
  name                    = var.name_prefix
  cluster_size            = var.cluster_size
  master_username         = var.master_username
  master_password         = var.master_password
  instance_class          = var.instance_class
  vpc_id                  = var.vpc_id
  subnet_ids              = var.subnet_ids
  allowed_security_groups = var.allowed_security_groups
  allowed_cidr_blocks     = var.allowed_cidr_blocks
  zone_id                 = ""
}


