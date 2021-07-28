# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/formio-s3
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "name_prefix" {
  type        = string
  description = "Used for overall naming of resources"
}

variable "aws_account_id" {
  type        = string
}

variable "kms_key_arn" {
  type        = string
}

variable "kms_key_policy_arn" {
  type        = string
}