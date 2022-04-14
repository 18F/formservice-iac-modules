###################################
# Global Vars
###################################
variable "name_prefix" { type = string }

###################################
# Task Definition Vars
###################################
variable "task_secrets" { type = string }

variable "enterprise_task_cpu" {
     type = number
     default = 1024
}
variable "enterprise_task_memory" {
     type = number
     default = 2048
}
variable "enterprise_image" { type = string }

variable "enterprise_ephemeral_storage" {
     type = number
     default = 25
}
variable "enterprise_volume_name" {
     type = string
     default = "enterprise-storage"
}
variable "container_mount_path" {
     type = string
     default = "/src/certs"
}
variable "efs_file_system_id" { type = string }
variable "efs_access_point_id" { type = string }

variable "log_stream_prefix" { 
     type = string
     default = "enterprise"
}
variable "aws_region" {
     type = string
     default = "us-gov-west-1"
}

###################################
# Load Balancer Vars
###################################
variable "vpc_id" { type = string }

variable "load_balancing_algo" { 
    type = string
    default = "least_outstanding_requests"
}

variable "health_path" { 
    type = string
    default = "/health"
}

variable "healthy_threshold" { 
    type = number
    default = 3
}

variable "unhealthy_threshold" { 
    type = number
    default = 3
}

variable "health_timeout" { 
    type = number 
    default = 5
}

variable "health_interval" { 
    type = number
    default = 30
}

variable "formio_alb_listener_arn" { type = string }

variable "customer_url" { type = string }

###################################
# ECS Service  Vars
###################################
variable "ecs_cluster_id" { type = string }

variable "service_desired_task_count" {
     type = number
     default = 3
}

variable "enable_execute_command" { 
     type = bool
     default = true
}

variable "force_new_deployment" { 
     type = bool
     default = true
}

variable "health_check_grace_period_seconds" { 
     type = number
     default = 120
}

variable "service_private_subnets" {
     type = list(string)
}

variable "service_security_group" {
     type = list(string)
}