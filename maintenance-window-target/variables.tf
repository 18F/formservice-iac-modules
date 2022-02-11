variable "target_key" {
  type          = string
  description   = "The key in the key-value pair for the targets to register with the maintenance window. In other words, the instances to run commands on when the maintenance window runs. You can specify targets using instance IDs, resource group names, or tags that have been applied to instances. For more information about these examples formats see (https://docs.aws.amazon.com/systems-manager/latest/userguide/mw-cli-tutorial-targets-examples.html)"
}

variable "target_name" {
  type          = string
  description   = "The name of the maintenance window target."
}

variable "target_resource_type" {
  type          = string
  description   = "The type of target being registered with the Maintenance Window. Possible values are INSTANCE and RESOURCE_GROUP."
}

variable "target_values" {
  type          = list
  description   = "The values in the key-value pair for the targets to register with the maintenance window. In other words, the instances to run commands on when the maintenance window runs. You can specify targets using instance IDs, resource group names, or tags that have been applied to instances. For more information about these examples formats see (https://docs.aws.amazon.com/systems-manager/latest/userguide/mw-cli-tutorial-targets-examples.html)"
}

variable "target_window_id" {
  type          = string
  description   = "The Id of the maintenance window to register the target with."
}
