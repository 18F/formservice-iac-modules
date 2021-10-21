# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/elastic-beanstalk vars
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "name_prefix" { type = string }

# variable "name" {}
variable "vpc_id" {}

variable "loadbalancer_subnets" {
  type        = string
  default     = ""
  description = "List of public subnet IDs to load balancer into"
}

variable "application_subnets" {
  type        = string
  default     = ""
  description = "List of private subnet IDs to install app into"
}
variable "allowed_security_groups" {
  type        = string
  default     = ""
  description = "List of security group ids allowed to access app"
}

variable "app_name" { }
variable "version_name" { }


variable "instance_type" { default = "t3.medium" }
variable "autoscale_min" { default = 3 }
variable "autoscale_max" { default = 5 }
variable "key_name" { default = "" }
variable "ssl_cert" { default = "" }

variable "asg_breach_duration" { default = "5" }
variable "asg_lower_breach_scale_increment" { default = "-1" }
variable "asg_lower_breach_threshold" { default = "2000000" }
variable "asg_scaling_measure_name" { default = "NetworkOut" }
variable "asg_scaling_period" { default = "5" }
variable "asg_scaling_statistic" { default = "Average" }
variable "asg_scaling_unit" { default = "Bytes" }
variable "asg_upper_breach_scale_increment" { default = "1" }
variable "asg_upper_breach_threshold" { default = "6000000" }
variable "beanstalk_ec2_role" { default = "" }
variable "DisableIMDSv1" { default = "" }
variable "ami_id" { default = "ami-020832866961d67b4" }

variable "ADMIN_EMAIL" { default = "" }
variable "ADMIN_PASS" { default = "" }
variable "DB_SECRET" { default = "" }
variable "JWT_SECRET" { default = "" }
variable "PORTAL_SECRET" { default = "" }

variable "LICENSE_KEY" { default = "" }
variable "MONGO" { default = "" }
variable "PORTAL_ENABLED" { default = "" }
variable "VPAT" { default = "" }
variable "ADMIN_KEY" { default = "" }

variable "FORMIO_S3_BUCKET" { default = "" }
variable "FORMIO_S3_REGION" { default = "" }
variable "FORMIO_S3_KEY" { default = "" }
variable "FORMIO_S3_SECRET" { default = "" }
