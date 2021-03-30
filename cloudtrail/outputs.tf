# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/apigw outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "cloudtrail" {
  value       = aws_cloudtrail.trail
  description = "Cloudtrail Resource"
}

# output "cloudtrail-lg" {
#   value       = aws_cloudwatch_log_group.cw-lg
#   description = "CloudTrail Log Group"
# }

# output "cloudtrail-s3-bucket" {
#   value       = aws_s3_bucket.trail
#   description = "CloudTrail S3 Bucket"
# }
