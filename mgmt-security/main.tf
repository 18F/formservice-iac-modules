# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-security
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

###################################
# security items for mgmt
###################################

###################################
# create user groups
###################################

resource "aws_iam_group" "kms_admins" {
  name = "KMS-Admins"
  path = "/"
}


############
# iam policy for kms managment
############
resource "aws_iam_policy" "faas_global_key_admin" {
  name        = "${var.name_prefix}-key-admin-policy"
  description = "Alow use of the ${var.name_prefix} EKS keys"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "kms:*"
    ],
    "Resource": [
      "arn:aws-us-gov:kms:*:${var.account_num}:key/*"
    ]
  }
}
EOF
}

resource "aws_iam_group_policy_attachment" "faas_key_admin_attach" {
  group      = aws_iam_group.kms_admins.name
  policy_arn = aws_iam_policy.faas_global_key_admin.arn
}

resource "aws_key_pair" "prodkey" {
  key_name   = "prod-ec2-key"
  public_key = "${var.prod-key-pub}"
}

############
# iam policy for Elastic Beanstalk Instances
############

resource "aws_iam_role" "beanstalk_ec2_role" {
  name = "elastic-beanstalk-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach1" {
  role       = aws_iam_role.beanstalk_ec2_role.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}
resource "aws_iam_role_policy_attachment" "attach2" {
  role       = aws_iam_role.beanstalk_ec2_role.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "attach3" {
  role       = aws_iam_role.beanstalk_ec2_role.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "attach4" {
  role       = aws_iam_role.beanstalk_ec2_role.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "attach5" {
  role       = aws_iam_role.beanstalk_ec2_role.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "attach6" {
  role       = aws_iam_role.beanstalk_ec2_role.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonS3FullAccess"
}