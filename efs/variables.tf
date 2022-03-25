variable "creation_token"  { type = string }
variable "backup_policy"  { 
     type = string
     default = "DISABLED"
}
variable "private_subnet_ids"  { type = list(string) }
variable "name_prefix" { type = string }
variable "kms_key_id" { type = string }