# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-hosts vars
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "name_prefix" {
  type        = string
  description = "Used for overall naming of resources"
  default     = "terraform linux instance"
}

variable "linux_ami" {}

variable "linux_instance_type" {}

variable "linux_monitoring" {default = "true"}

variable "vpc_id" {}
variable "subnet_id" {}
variable "kms_key" {default = ""}
variable "key_pair" {default = ""}

variable "linux_root_block_size" {
  type        = string
  description = "Size in GB of root_block_device"
  default     = "50"
}

variable "linux_ingress_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of sg ingress cidr blocks"
}

variable "iam_instance_profile" {
  type        = string
  default     = ""
  description = "IAM Instance Role"
}

variable "user_data" {
  type        = string
  default     = ""
  description = "input for user data"
}