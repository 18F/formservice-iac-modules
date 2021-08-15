# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/vpc endpoint vars
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "name_prefix" {
  type    = string
  description = "Used for overall naming of resources"
  default = ""
}

variable "vpc_id" {
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

variable "endpointSGList" {
  type    = list(string)
  default = [""]
}

variable "private_subnets" {
  type    = list(string)
  default = [""]
}