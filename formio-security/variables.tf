# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/formio-security variables
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "name_prefix" {
  type        = string
  description = "Used for overall naming of resources"
}

variable "account_num" {
  type        = string
  description = "AWS Account Number"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "Used the vpc id"
}

variable "formio_alb_allowed_cidr_blocks" {
  default     = "0.0.0.0/0"
  description = "List of CIDR blocks to be allowed to connect to the FormIO ALB"
}