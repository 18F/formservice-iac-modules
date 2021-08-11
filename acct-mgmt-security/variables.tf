# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-security variables
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

variable "prod-key-pub" {
  type        = string
  description = "Public Key for EC2 Instances"
}