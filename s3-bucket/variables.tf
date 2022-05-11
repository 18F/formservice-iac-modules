variable "bucket_prefix" {
  type        = string
  description = "Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. Must be lowercase and less than or equal to 37 characters in length."
  default     = ""
}

variable "expiration_days" {
  type        = number
  description = "The lifetime, in days, of the objects that are subject to the rule. The value must be a non-zero positive integer."
  default     = 365
}

variable "lifecycle_configuration_rule_id" {
  type        = string
  description = "Unique identifier for the rule. The value cannot be longer than 255 characters."
  default     = ""
}

variable "status" {
  type        = string
  description = "Whether the rule is currently being applied. Valid values: Enabled or Disabled."
  default     = "Enabled"
}
