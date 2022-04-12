output "fsap_id" {
  description = "ARN for the file system access points"
  value       = aws_efs_access_point.mountpoint.id
}

output "fs_id" {
  description = "ARN for the file system"
  value       = aws_efs_file_system.fs.id
}