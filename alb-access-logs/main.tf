data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "alb_access_logs" {
  bucket = "${var.project}-${var.env}-alb-access-logs"

  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["READ", "WRITE", "READ_ACP", "WRITE_ACP"]
  }

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 0
    enabled                                = true
    id                                     = "${var.project}-${var.days}-day-delete"

    expiration {
      days                         = ${var.days}
      expired_object_delete_marker = false
    }
  }

  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = false

      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_access_logs" {
  bucket = aws_s3_bucket.alb_access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "alb_access_logs" {
  bucket = aws_s3_bucket.alb_access_logs.id
  policy = data.aws_iam_policy_document.alb_access_logs.json
}

data "aws_iam_policy_document" "alb_access_logs" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws-us-gov:s3:::${var.project}-${var.env}-alb-access-logs/*/AWSLogs/${var.account_num}/*"]
    actions   = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws-us-gov:iam::048591011584:root"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws-us-gov:s3:::${var.project}-${var.env}-alb-access-logs/*/AWSLogs/${var.account_num}/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws-us-gov:s3:::${var.project}-${var.env}-alb-access-logs"]
    actions   = ["s3:GetBucketAcl"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}
