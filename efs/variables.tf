variable "creation_token"  { type = string }
variable "backup_policy"  { 
     type = string
     default = "DISABLED"
}
variable "private_subnet_ids"  { type = list(string) }
variable "name_prefix" { type = string }
variable "kms_key_id" { type = string }
variable "allowed_security_groups" { 
     type = list(string)
     default = [""]
}
variable "vpc_id" { type = string }
variable "efs_allowed_subnet_cidrs" { type = list(string) }