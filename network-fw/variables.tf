variable "name_prefix" {
    type = string
}

variable "firewall_policy_arn" { type = string }

variable "vpc_id" { type = string }

variable "subnet_mapping" {
    type = any
}

variable "firewall_policy_change_protection" {
    type = bool
    default = false
}
variable "subnet_change_protection" {
    type = bool
    default = false
}
variable "delete_protection" {
    type = bool
    default = false
}