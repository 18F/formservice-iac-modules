output "fsap_arn" {
  description = "ARN for the file system access points"
  value       = aws_efs_access_point.mountpoint.arn
}

