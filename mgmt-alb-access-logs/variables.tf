variable "account_num" {
  type        = string
  description = "AWS Account Number"
}

variable "env" {
  type        = string
  description = "Environment label"
}

variable "project" {
  type        = string
  description = "The name of the project."
}

variable "region" {
  type        = string
  description = "The AWS region this bucket resides in."
}
