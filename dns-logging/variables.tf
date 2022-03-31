variable "name_prefix" { type = string }
variable "kms_key_id" { type = string }
variable "log_retention_days" { 
    type = number
    default = 180
}