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

provider "aws" {
  region  = "${var.region}"
}

data "aws_s3_object" "post_install_script" {
  bucket  = "faas-prod-mgmt-bucket"
  key     = "mgmt-server/mgmt-server-post-install.sh"
}

resource "aws_ebs_encryption_by_default" "enabled" {
  enabled = true
}

resource "aws_instance" "this" {
  ami                   = var.ami
  instance_type         = var.instance_type
  subnet_id             = var.subnet_id
  iam_instance_profile  = var.iam_instance_profile
  security_groups       = var.security_groups

  user_data = data.aws_s3_object.post_install_script.body

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.purpose}"
  }

  provisioner "local-exec" {
    command = "${var.local_exec_command}"
  }

}
