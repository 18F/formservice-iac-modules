variable "account_num" {
  type        = string
  description = "AWS Account Number"
}

variable "env" {
   type        = string
   description = "Environment label"
}

variable "maintenance_window_name" {
  type        = string
  description = "The name of the maintenance window."
}

variable "maintenance_window_schedule" {
  type        = string
  description = "The schedule of the Maintenance Window in the form of a cron or rate expression."
}

variable "maintenance_window_duration" {
  type        = string
  description = "The duration of the Maintenance Window in hours."
}

variable "maintenance_window_cutoff" {
  type        = string
  description = "The number of hours before the end of the Maintenance Window that Systems Manager stops scheduling new tasks for execution."
}
