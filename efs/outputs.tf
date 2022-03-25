output "faas_formio_repo_enterprise" {
  description = "URL of the FormIO Enterprise Repository"
  value       = aws_ecr_repository.formio-enterprise.repository_url
}

output "faas_formio_repo_pdf-server" {
  description = "URL of the FormIO PDF Server Repository"
  value       = aws_ecr_repository.formio-pdf-server.repository_url
}

output "faas_formio_repo_submission-server" {
  description = "URL of the FormIO Submission ServerRepository"
  value       = aws_ecr_repository.formio-submission-server.repository_url
}

output "faas_formio_repo_utils-redis" {
  description = "URL of the FormIO Redis Repository"
  value       = aws_ecr_repository.formio-utils-redis.repository_url
}

output "faas_formio_repo_utils-nginx" {
  description = "URL of the FormIO NGINX Repository"
  value       = aws_ecr_repository.formio-utils-nginx.repository_url
}
