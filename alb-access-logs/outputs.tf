output "bucket_name" {
  value       = aws_s3_bucket.alb_access_logs.id
  description = "The name of the bucket."
}
