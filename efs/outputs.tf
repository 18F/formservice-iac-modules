output "fsap_id" {
  description = "ARN for the file system access points"
  value       = aws_efs_access_point.mountpoint.id
}

output "api_fsap_id" {
  description = "ARN for the file system access points"
  value       = aws_efs_access_point.api_server.id
}

output "pdf_fsap_id" {
  description = "ARN for the file system access points"
  value       = aws_efs_access_point.pdf_server.id
}

output "nginx_certs_fsap_id" {
  description = "ARN for the file system access points"
  value       = aws_efs_access_point.nginx_certs.id
}

output "fs_id" {
  description = "ARN for the file system"
  value       = aws_efs_file_system.fs.id
}