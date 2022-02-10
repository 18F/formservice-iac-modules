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

variable "local_exec_command" {
  type        = string
  description = "Invokes a local executable after a resource is created. This invokes a process on the machine running Terraform, not on the resource."
  default     = "echo 'This is an example of a local_exec command'"
}

variable "project" {
  type        = string
  description = "The name of the project."
}

variable "purpose" {
  type        = string
  description = "The purpose of this instance."
}

variable "region" {
  type        = string
  description = "The region where AWS operations will take place."
}

variable "security_groups" {
  type        = list
  description = "A list of security group names to associate with."
}

variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch in."
}

variable "volume_size" {
  type        = number
  description = "Size of the volume in gibibytes (GiB)."
}
