# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-hosts
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

resource "aws_ebs_encryption_by_default" "enabled" {
  enabled = true
}

###############
# Terraform Linux
###############
module "ec2_linux" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">=2.15.0"

  name           = "${var.name_prefix}terraform-linux"
  instance_count = 1

  ami           = var.linux_ami
  instance_type = var.linux_instance_type

  subnet_id              = var.subnet_id
  monitoring = var.linux_monitoring
  iam_instance_profile = var.iam_instance_profile
  user_data = << EOF
		#! /bin/bash
    sudo yum update
		sudo install -y git
		sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    sudo yum -y install terraform
	EOF

  root_block_device = [
    {
      volume_size = var.linux_root_block_size
      volume_type = "gp2",
      encrypted   = true,
      kms_key_id = var.kms_key
    },
  ]

  # ebs_block_device = [
  #   {
  #     device_name           = "/dev/xvdz"
  #     volume_type           = "gp2"
  #     volume_size           = "50"
  #     delete_on_termination = true,
  #     encrypted   = true
  #   }
  # ]

  tags = {
    "Env"  = "Private"
    "Name" = "${var.name_prefix}-terraform-linux"
  }
}
###################################
# security group for terraform linux
###################################
/* resource "aws_security_group" "terraform_linux_sg" {
  name        = "${var.name_prefix}-terraform-linux-sg"
  description = "Allow ssh and rdp connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.linux_ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-bastion-linux-sg"
  }
}
 */