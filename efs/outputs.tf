output "fsap_arn" {
  description = "ARN for the file system access points"
  value       = aws_efs_access_point.mountpoint.arn
}

output "fs_arn" {
  description = "ARN for the file system"
  value       = aws_efs_file_system.fs.arn
}