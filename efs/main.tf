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

locals {
  private_subnet_count = length(var.private_subnet_ids)

}

####################################
# EFS Standup
####################################

resource "aws_efs_file_system" "fs" {
  creation_token = var.creation_token

  encrypted = true
  kms_key_id =var.kms_key_id

  tags = {
    Name = "${var.name_prefix}-efs"
  }
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.fs.id

  bypass_policy_lockout_safety_check = false

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "ExamplePolicy01",
    "Statement": [
        {
            "Sid": "ExampleStatement01",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.fs.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.fs.id

  backup_policy {
    status = var.backup_policy
  }
}

resource "aws_efs_mount_target" "mout_point" {
  count = local.private_subnet_count
  file_system_id = aws_efs_file_system.fs.id
  subnet_id      = var.private_subnet_ids[count.index]
}

resource "aws_efs_access_point" "mountpoint" {
  file_system_id = aws_efs_file_system.fs.id
  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    creation_info {
      owner_gid = 1000
      owner_uid = 1000
      permissions = 777
    }

    path = "formio"
  }
}