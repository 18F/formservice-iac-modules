variable "account_num" {
  type        = string
  description = "The AWS account number."
}

variable "ami" {
  type        = string
  description = "AMI to use for the instance."
}

variable "env" {
  type        = string
  description = "The name of the infrastructure environment."
}

variable "instance_type" {
  type        = string
  description = "The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance."
}

variable "project" {
  type        = string
  description = "The name of the project."
}

variable "volume_size" {
  type        = number
  description = "Size of the volume in gibibytes (GiB)."
}

variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch in."
}
