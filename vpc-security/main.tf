terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.25.1 and above) recommends Terraform 0.13.3 or above.
  required_version = ">= 0.13.3"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.7.0"
    }
  }
}



resource "aws_security_group" "endpoint-sg" {
  name        = "${var.name_prefix}-endpoint-sg"
  description = "Allow connections to endpoints from within the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = tolist(var.vpc_cider_block)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = tolist(var.vpc_cider_block)
  }

  tags = {
    Name = "${var.name_prefix}-endpoint-sg"
  }
} 