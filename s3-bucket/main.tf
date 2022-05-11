resource "aws_s3_bucket" "this" {
  bucket_prefix = var.bucket_prefix
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    id      = var.lifecycle_configuration_rule_id
    status  = var.lifecycle_configuration_rule_status

    expiration {
      days  = var.expiration_days
    }
  }
}
