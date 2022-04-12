variable "name_prefix" { type = string }
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
variable "aws_region" {
     type = string
     default = "us-gov-west-1"
}
