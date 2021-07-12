# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/documentdb vars
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "name_prefix" {
  type    = string
  description = "Used for overall naming of resources"
  default = "test-name"
}
                                
variable "cluster_size"             {}             
variable "master_username"          {}         
variable "master_password"          {}     
variable "instance_class"           {}  
variable "vpc_id"                   {} 

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of subnet IDs to install DocumentDB cluster into"
}

/* variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of existing Security Groups to be allowed to connect to the DocumentDB cluster"
} */

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the DocumentDB cluster"
}
variable "zone_id" {
  default = ""
} 

variable "kms_key_id" {
  default = ""
}