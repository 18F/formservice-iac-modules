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
      version = ">= 4.0.0"
    }
  }
}

############
# s3 Bucket
############
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.name_prefix}-bucket"  
  tags = {
    name = "${var.name_prefix}-s3-bucket"
  }
  
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

  # Enable server-side encryption by default
 resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_cors_configuration" "bucket_cors" {
  bucket = aws_s3_bucket.bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = [""]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "retention-config" {
  count = var.retention ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  rule {
    id = "data-retention-limit"

    expiration {
      days = var.retention_days
    }

    status = "Enabled"
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

resource "aws_iam_user_policy_attachment" "use-attach" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_user_policy_attachment" "key-use-attach" {
  user       = aws_iam_user.user.name
  policy_arn = var.kms_key_policy_arn
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
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
              "s3:GetAccessPoint",
              "s3:PutAccountPublicAccessBlock",
              "s3:GetAccountPublicAccessBlock",
              "s3:ListAllMyBuckets",
              "s3:ListAccessPoints",
              "s3:ListJobs",
              "s3:CreateJob",
              "s3:HeadBucket"
          ],
          "Resource": "*"
      },
      {
          "Sid": "VisualEditor1",
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
