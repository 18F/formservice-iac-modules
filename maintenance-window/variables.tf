variable "cutoff" {
  type        = string
  description = "The number of hours before the end of the Maintenance Window that Systems Manager stops scheduling new tasks for execution."
}

variable "duration" {
  type        = string
  description = "The duration of the Maintenance Window in hours."
}

variable "name" {
  type        = string
  description = "The name of the maintenance window."
}

variable "schedule" {
  type        = string
  description = "The schedule of the Maintenance Window in the form of a cron or rate expression."
}
