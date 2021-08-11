# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/acct-mgmt-security variables
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

variable "key-pub" {
  type        = string
  description = "Public Key for EC2 Instances"
}

variable "env" {
   type        = string
   description = "Environment label"
}