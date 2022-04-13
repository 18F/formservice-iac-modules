# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/formio-security
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
# security items for formIO
###################################


resource "aws_kms_key" "s3_bucket_key" {
  description               = "${var.name_prefix}-s3-bucket-key"
  key_usage                 = "ENCRYPT_DECRYPT"
  customer_master_key_spec  = "SYMMETRIC_DEFAULT"
  enable_key_rotation       = true

}

resource "aws_kms_alias" "s3_bucket_key" {
  name          = "alias/${var.name_prefix}-s3-bucket-key"
  target_key_id = aws_kms_key.s3_bucket_key.key_id
}

############
# iam policy for s3 bucket key
############
resource "aws_iam_policy" "s3_key_user" {
  name        = "${var.name_prefix}-s3-key-user-policy"
  description = "Allow use of the ${var.name_prefix} s3 bucket key"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ],
    "Resource": [
      "arn:aws-us-gov:kms:${var.region}:${var.account_num}:key/${aws_kms_key.s3_bucket_key.key_id}"
    ]
  }
}
EOF
}

resource "aws_kms_key" "documentDB_key" {
  description               = "${var.name_prefix}-documentDB-key"
  key_usage                 = "ENCRYPT_DECRYPT"
  customer_master_key_spec  = "SYMMETRIC_DEFAULT"
  enable_key_rotation       = true

}

resource "aws_kms_alias" "documentDB_key" {
  name          = "alias/${var.name_prefix}-documentDB-key"
  target_key_id = aws_kms_key.documentDB_key.key_id
}

############
# iam policy for documentDB key
############
resource "aws_iam_policy" "documentDB_key_user" {
  name        = "${var.name_prefix}-documentDB-key-user-policy"
  description = "Allow use of the ${var.name_prefix} documentDB key"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ],
    "Resource": [
      "arn:aws-us-gov:kms:${var.region}:${var.account_num}:key/${aws_kms_key.documentDB_key.key_id}"
    ]
  }
}
EOF
}

############
# Security Groups for FormIO ALB and ECS
############

resource "aws_security_group" "formio_alb_sg" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow Connections to the Load Balancer"
  vpc_id      = var.vpc_id

 ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = tolist([ var.formio_alb_allowed_cidr_blocks ])
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = tolist([ var.formio_alb_allowed_cidr_blocks ])
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"
    Environment = "${var.name_prefix}"
  }
} 

resource "aws_security_group" "formio_ecs_sg" {
  name        = "${var.name_prefix}-ecs-sg"
  description = "Allow Connections to the Load Balancer"
  vpc_id      = var.vpc_id

 ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "TCP"
    security_groups = [ aws_security_group.formio_alb_sg.id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-ecs-sg"
    Environment = "${var.name_prefix}"
  }

  depends_on = [ aws_security_group.formio_alb_sg ]
} 