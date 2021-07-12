# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/formio-s3
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

############
# s3 Bucket
############
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.name_prefix}-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm = "aws:kms"
      }
    }
  }
  tags = {
    name = "${var.name_prefix}-s3-bucket"
  }
}

###########
# iam user 
###########

resource "aws_iam_user" "user" {
  name = "${var.name_prefix}-s3-user"
  path = "/system/"
}

resource "aws_iam_access_key" "access_key" {
  user    = aws_iam_user.user.name
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.policy.arn
}

############
# iam policy
############
resource "aws_iam_policy" "policy" {
  name        = "${var.name_prefix}-s3-policy"
  description = "Allow access to ${var.name_prefix} s3 bucket"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "BucketFullAccess",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "${aws_s3_bucket.bucket.arn}",
                "arn:aws-us-gov:s3:*:${var.aws_account_id}:accesspoint/*",
                "arn:aws-us-gov:s3:*:*:job/*",
                "${aws_s3_bucket.bucket.arn}/*"
            ]
        }
    ]
}
EOF
}
