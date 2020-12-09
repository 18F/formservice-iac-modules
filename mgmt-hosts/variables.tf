# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-hosts vars
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "name_prefix" {
  type        = string
  description = "Used for overall naming of resources"
  default     = "ide-sandb-hyperscience"
}

variable "linux_ami" {}
variable "windows_ami" {}

variable "linux_instance_type" {}
variable "windows_instance_type" {}

variable "linux_monitoring" {default = "true"}
variable "windows_monitoring" {default = "true"}

variable "vpc_id" {}
variable "subnet_id" {}
variable "key_pair" { default = "faas-sandb-bastion"}

variable "linux_root_block_size" {
  type        = string
  description = "Size in GB of root_block_device"
  default     = "50"
}

variable "windows_root_block_size" {
  type        = string
  description = "Size in GB of root_block_device"
  default     = "50"
}

variable "linux_ingress_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of sg ingress cidr blocks"
}

variable "windows_rdp_ingress_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of sg ingress cidr blocks"
}

variable "windows_tls_ingress_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of sg ingress cidr blocks"
}