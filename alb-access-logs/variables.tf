variable "account_num" {
  type        = string
  description = "AWS Account Number"
}

variable "env" {
  type        = string
  description = "Environment label"
}

variable "expiration_days" {
  type        = number
  description = "Specifies the number of days after object creation when the specific rule action takes effect."
  default     = 180
}

variable "project" {
  type        = string
  description = "The name of the project."
}
