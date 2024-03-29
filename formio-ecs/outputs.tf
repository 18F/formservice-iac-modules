output "ecs_cluster_id" {
  description = "ID for the ECS Cluster Instance"
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_cluster_name" {
  description = "ID for the ECS Cluster Instance"
  value       = aws_ecs_cluster.ecs_cluster.name
}