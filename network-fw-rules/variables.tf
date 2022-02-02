variable "rule_name" {
    type = string
}
variable "allowed_networks" {
    type = list(string)
    default = ["10.0.0.0/8"]
}
variable "allowed_domains" {
    type = list(string)
    default = [".example.com"]
}
