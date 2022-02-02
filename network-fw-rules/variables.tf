variable "rule_name" {
    type = string
}
variable "home_networks" {
    type = list(string)
    default = ["10.0.0.0/8"]
}
variable "rule_type" {
    type = string
}
variable "filtered_domains" {
    type = list(string)
    default = [".example.com"]
}
