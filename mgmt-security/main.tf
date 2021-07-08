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

/* resource "aws_kms_key" "documentDB_key" {
  description               = "${var.name_prefix}-documentDB-key"
  key_usage                 = "ENCRYPT_DECRYPT"
  customer_master_key_spec  = "RSA_4096"
  
}

resource "aws_kms_alias" "documentDB_key" {
  name          = "alias/${var.name_prefix}-documentDB-key"
  target_key_id = aws_kms_key.s3_bucket_key.key_id
}

############
# iam policy for documentDB key
############
resource "aws_iam_policy" "documentDB_key_user" {
  name        = "${var.name_prefix}-documentDB-key-user-policy"
  description = "Alow use of the ${var.name_prefix} EKS keys"
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
      "arn:aws:kms:${var.region}:${var.account_num}:key/${aws_kms_key.documentDB_key.key_id}",
      "arn:aws:kms:${var.region}:${var.account_num}:key/${aws_kms_key.documentDB_key.key_id}"
    ]
  }
}
EOF
}
 */