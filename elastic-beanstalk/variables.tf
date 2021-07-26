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

variable "beanstalk_ec2_role" { default = "" }

variable "ADMIN_EMAIL" {  }
variable "ADMIN_PASS" {  }
variable "DB_SECRET" {  }
variable "JWT_SECRET" {  }

variable "LICENSE_KEY" {  }
variable "MONGO" {  }
variable "PORTAL_ENABLED" {  }
variable "VPAT" {  }

variable "FORMIO_S3_BUCKET" {  }
variable "FORMIO_S3_REGION" {  }
variable "FORMIO_S3_KEY" {  }
variable "FORMIO_S3_SECRET" {  }

variable "PORT" {  }
variable "DEFAULT_DATABASE" {  }
variable "PER_PROJECT_DBS" {  }
variable "PROXY" {  }
variable "PRIMARY" {  }
