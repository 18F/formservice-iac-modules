output "faas_formio_ecs_alb_id" {
  description = "ALB id for Formio ECS instance"
  value       = aws_lb.formio_lb.id
}

output "faas_formio_ecs_alb_dns_name" {
  description = "ALB DNS name for Formio ECS instance"
  value       = aws_lb.formio_lb.dns_name
}

output "faas_formio_alb_listener" {
  description = "ALB Target Group id for Formio ECS main instance"
  value       = aws_lb_listener.main.arn
}

output "faas_formio_autoscaling_prefx" {
  description = "alb arn portion required for autoscaling resource labels "
  value       = regex("app/.", aws_lb.formio_lb.arn)
}