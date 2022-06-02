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

################################
# Security Groups for FormIO EFS
################################

resource "aws_security_group" "formio_efrs_sg" {
  name        = "${var.name_prefix}-efs-sg"
  description = "Allow Connections to EFS"
  vpc_id      = var.vpc_id

 ingress {
    description     = "NFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "TCP"
    cidr_blocks     = var.efs_allowed_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-efs-sg"
    Environment = "${var.name_prefix}"
  }
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
  file_system_id  = aws_efs_file_system.fs.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [ aws_security_group.formio_efrs_sg.id ]
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

    path = "/formio"
  }
}

resource "aws_efs_access_point" "api_server" {
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

    path = "/formio/nginx/api-conf"
  }
}

resource "aws_efs_access_point" "pdf_server" {
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

    path = "/formio/nginx/pdf-conf"
  }
}

resource "aws_efs_access_point" "nginx_certs" {
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

    path = "/formio/nginx/certs"
  }
}