output "sns_topic_arn" {
  description = "ARN for the SNS Topic"
  value       = aws_sns_topic.formio_alerts.arn
}