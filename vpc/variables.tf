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
variable "route_table" {
  type    = string
  default = [ rtb-05f5b51d08a2d4b9c, rtb-030b6d714908a02d9 ]
}
