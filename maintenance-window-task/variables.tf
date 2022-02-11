variable "task_max_concurrency" {
  type        = number
  description = "The maximum number of targets this task can be run for in parallel."
}

variable "task_max_errors" {
  type        = number
  description = ""
}

variable "task_priority" {
  type        = string
  description = ""
}

variable "task_task_arn" {
  type        = string
  description = ""
}

variable "task_task_type" {
  type        = string
  description = ""
}

variable "task_window_id" {
  type        = string
  description = "The Id of the maintenance window to register the task with."
}

variable "task_key" {
  type        = string
  description = ""
}

variable "task_target_values" {
  type        = string
  description = ""
}

variable "timeout_seconds" {
  type        = string
  description = ""
}

variable "cloudwatch_output_enabled" {
  type        = string
  description = ""
}

variable "commands" {
  type        = string
  description = ""
}
