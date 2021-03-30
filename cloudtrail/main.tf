# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/cloudtrail
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

########################################
# CloudTrail
########################################


#Module      : CLOUDTRAIL
#Description : Terraform module to provision an AWS CloudTrail with encrypted S3 bucket.
#              This bucket is used to store CloudTrail logs.
resource "aws_cloudtrail" "trail" {
  # count = var.enabled_cloudtrail == true ? 1 : 0

  name                          = "cloudtrail-${var.name_prefix}"
  enable_logging                = true
  s3_bucket_name                = "var.s3_bucket_name"
  enable_log_file_validation    = true
  is_multi_region_trail         = false
  include_global_service_events = true
  # cloud_watch_logs_role_arn     = ""
  cloud_watch_logs_group_arn    = "var.cloud_watch_logs_group_arn"
  cloud_watch_logs_role_arn     = "var.cloud_watch_logs_role_arn"
  # kms_key_id                  = var.kms_key_id
  sns_topic_name                = "var.sns_topic_name"

  # event_selector {
  #   read_write_type           = "All"
  #   include_management_events = true

  #   data_resource {
  #     type   = "AWS::Lambda::Function"
  #     values = ["arn:aws:lambda"]
  #   }
  # }

  # event_selector {
  #   read_write_type           = "All"
  #   include_management_events = true

  #   data_resource {
  #     type   = "AWS::S3::Object"
  #     values = ["arn:aws:s3:::"]
  #   }
  # }

  dynamic "event_selector" {
    for_each = var.event_selector ? [true] : []
    content {
      read_write_type           = var.read_write_type
      include_management_events = var.include_management_events
      dynamic "data_resource" {
        for_each = var.event_selector_data_resource ? ["true"] : []
        content {
          type   = var.data_resource_type
          values = var.data_resource_values
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [event_selector]
  }
}

resource "aws_s3_bucket" "trail" {
  bucket        = "cloudtrail-${var.name_prefix}-bucket"
  force_destroy = true
}  