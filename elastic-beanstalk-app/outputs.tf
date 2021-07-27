# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/elastic-beanstalk app outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



output "app_name" {
  value       = aws_elastic_beanstalk_application.app.name
  description = "FormIO App Name."
}

output "version_name" {
  value       = aws_elastic_beanstalk_application_version.initial.name
  description = "FormIO Version Name."
}