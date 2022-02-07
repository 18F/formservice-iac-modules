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

variable "iam_instance_profile" {
  type        = string
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
}

variable "instance_type" {
  type        = string
  description = "The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance."
}

variable "local_exec" {
  type        = string
  description = "Invokes a local executable after a resource is created. This invokes a process on the machine running Terraform, not on the resource."
}

variable "project" {
  type        = string
  description = "The name of the project."
}

variable "remote_exec" {
  type        = string
  description = "Invokes a script on a remote resource after it is created."
}

variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch in."
}

variable "volume_size" {
  type        = number
  description = "Size of the volume in gibibytes (GiB)."
}