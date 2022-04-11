variable "name" {
  type        = string
  description = "The name of the patch baseline."
}

variable "operating_system" {
  type        = string
  description = "Defines the operating system the patch baseline applies to."
  default     = "AMAZON_LINUX_2"
}
