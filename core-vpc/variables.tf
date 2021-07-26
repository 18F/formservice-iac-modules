# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-vpc vars
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "name_prefix" {
  type    = string
  description = "Used for overall naming of resources"
  default = "app-vpc-01"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "transit_gateway_id" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}

variable "project" {
  type    = string
  default = ""
}