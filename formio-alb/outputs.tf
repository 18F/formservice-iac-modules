output "faas_formio_ecs_alb_id" {
  description = "ALB id for Formio ECS instance"
  value       = aws_lb.formio_lb.id
}

output "faas_formio_ecs_alb_dns_name" {
  description = "ALB DNS name for Formio ECS instance"
  value       = aws_lb.formio_lb.dns_name
}

output "faas_formio_ecs_alb_tg_main" {
  description = "ALB Target Group id for Formio ECS main instance"
  value       = aws_lb_target_group.main.id
}

output "faas_formio_ecs_alb_tg_pdf" {
  description = "ALB Target Group id for Formio ECS pdf server instance"
  value       = length(aws_lb_target_group.pdf_server.id) > 0 ? aws_lb_target_group.pdf_server.id : null
}