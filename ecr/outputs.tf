output "faas_formio_repo" {
  description = "URL of the FormIO Repository"
  value       = aws_ecr_repository.formio.repository_url
}

output "faas_signreq_repo" {
  description = "URL of the Sign Request Repository"
  value       = aws_ecr_repository.signreq.repository_url
}