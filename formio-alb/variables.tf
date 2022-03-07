variable "name_prefix" { type = string }
variable "hub" {
     type = bool
     default = true
}

variable "vpc_id" { type = string }
variable "public_subnet_ids" { }
variable "allowed_security_group_id" { type = string }


variable "enable_deletion_protection" { 
     type = bool
     default = false
}
variable "enable_access_logs" {
     type = bool
     default = false
}
variable "access_logs_bucket_name" {
     type = string
     default = ""
}

variable "ssl_policy" {
     type = string 
     default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}
variable "certificate_arn" { type = string }
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
