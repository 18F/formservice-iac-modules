# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/tgw-routes vars
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "name_prefix" {
  type    = string
  description = "Used for overall naming of resources"
  default = "app-vpc-01"
}

variable "transit_gateway_id" {
  type    = string
  description = "TGW ID"
}

variable "vpc_id" {
  type    = string
}

variable "destination_cidr_block" {
  type    = string
}

variable "public_subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of IDs of public subnets"
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of IDs of private subnets"
}

variable "default_route_table_id" {
  type        = string
  default     = ""
  description = "The default route table ID"
}

variable "public_route_table_ids" {
  type        = list(string)
  default     = []
  description = "List of IDs of public route tables"
}

variable "private_route_table_ids" {
  type        = list(string)
  default     = []
  description = "List of IDs of private route tables"
}

variable "inspection_route_table_ids" {
  type        = list(string)
  default     = []
  description = "List of IDs of inspection route tables"
}
variable "database_route_table_ids" {
  type        = list(string)
  default     = []
  description = "List of IDs of database route tables"
}

variable "appliance_mode_support" {
  type        = string
  default     = "disable"
  description = "Enable appliance mode for the transit gateway to allow for firewall appliances and centralized egress"
}