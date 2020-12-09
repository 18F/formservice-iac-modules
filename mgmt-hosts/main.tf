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



###############
# Bastion Linux
###############
module "ec2_linux" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.15.0"

  name           = "${var.name_prefix}-linux-bastion"
  instance_count = 1

  ami           = var.linux_ami
  instance_type = var.linux_instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.linux_bastion.id]
  key_name              = var.key_pair
  monitoring = var.linux_monitoring

  root_block_device = [
    {
      volume_size = var.linux_root_block_size
      volume_type = "gp2"
    },
  ]

  # ebs_block_device = [
  #   {
  #     device_name           = "/dev/xvdz"
  #     volume_type           = "gp2"
  #     volume_size           = "50"
  #     delete_on_termination = true
  #   }
  # ]

  tags = {
    "Env"  = "Private"
    "Name" = "${var.name_prefix}-linux-bastion"
  }
}
###################################
# security group for linux bastions
###################################
resource "aws_security_group" "linux_bastion" {
  name        = "${var.name_prefix}-linux-bastion-sg"
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
#################
# Tester Windows
#################
module "ec2_windows" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.15.0"

  name           = "${var.name_prefix}-windows-tester"
  instance_count = 1

  ami           = var.windows_ami
  instance_type = var.windows_instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.win_bastion.id]
  key_name              = var.key_pair
  monitoring = var.windows_monitoring

  root_block_device = [
    {
      volume_size = var.windows_root_block_size
      volume_type = "gp2"
    },
  ]

  tags = {
    "Env"  = "Private"
    "Name" = "${var.name_prefix}-windows-tester"
  }
}
###################################
# security group for windows bastions
###################################
resource "aws_security_group" "win_bastion" {
  name        = "${var.name_prefix}-win-testing-sg"
  description = "Allow ssh and rdp connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.windows_rdp_ingress_cidr_blocks
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = var.windows_tls_ingress_cidr_blocks
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.windows_tls_ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-win-testing-sg"
  }
}