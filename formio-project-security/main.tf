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
# security items for formIO Projects
###################################


resource "aws_kms_key" "s3_bucket_key" {
  description               = "${var.name_prefix}-s3-bucket-key"
  key_usage                 = "ENCRYPT_DECRYPT"
  customer_master_key_spec  = "SYMMETRIC_DEFAULT"
  enable_key_rotation       = "true"
  
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
  description = "Alow use of the ${var.name_prefix} s3 bucket key"
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
