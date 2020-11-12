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

variable "app_version_bucket" { default = "" }
variable "app_version_source" { default = "" }

variable "instance_type" { default = "t3.medium" }
variable "autoscale_min" { default = 3 }
variable "autoscale_max" { default = 5 }
variable "key_name" { default = "" }
variable "ssl_cert" { default = "" }

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

# variable "env_vars" {
#   type        = map(string)
#   default = {
#     "ADMIN_EMAIL" = "leonard.becraft@gsa.gov"
#     "ADMIN_PASS"  = "formio_admin_password"
#     "DB_SECRET"   = "super_secret_password"
#     "JWT_SECRET"  = "super_secret_password"

#     "LICENSE_KEY"    = "formio_license_key"
#     "MONGO"          = "mongodb://formio:<password>@<cluster_endpoint>:27017/formio?ssl=true"
#     "PORTAL_ENABLED" = "true"
#     "VPAT"           = "true"

#     "FORMIO_S3_BUCKET" = "" # s3 bucket name
#     "FORMIO_S3_REGION" = "" 
#     "FORMIO_S3_KEY"    = "" # pdf user access key
#     "FORMIO_S3_SECRET" = "" # pdf user secret key
#   }
# }
