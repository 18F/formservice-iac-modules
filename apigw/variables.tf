
variable "name_prefix" {
  type        = string
  description = "Used for overall naming of resources"
}

variable "name" {
  default = ""
} 

variable "identity_source" {
  default = ""
} 

variable "provider_arns" {
  default = ""
} 

variable "binary_media_types" {
  default = ""
} 

variable "minimum_compression_size" {
  default = ""
} 

variable "retention_in_days" {
  type        = string
  default = "90"
} 

variable "tags" {
  default = "API-Gateway"
} 

variable "integration_type" {  }
variable "integration_method" {  }
variable "integration_uri" {  }
