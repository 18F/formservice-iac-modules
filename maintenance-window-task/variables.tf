variable "cloudwatch_output_enabled" {
  type        = bool
  description = "Enables Systems Manager to send command output to CloudWatch Logs."
}

variable "commands" {
  type        = list
  description = "An array of commands to run."
}

variable "max_concurrency" {
  type        = number
  description = "The maximum number of targets this task can be run for in parallel."
}

variable "max_errors" {
  type        = number
  description = "The maximum number of errors allowed before this task stops being scheduled."
}

variable "priority" {
  type        = number
  description = "The priority of the task in the Maintenance Window, the lower the number the higher the priority. Tasks in a Maintenance Window are scheduled in priority order with tasks that have the same priority scheduled in parallel."
}

variable "target_ids" {
  type        = list
  description = "The ids of the targets (either instances or window target ids). Example values: i-0ce6656f9f896e68b, ea9a473f-ae6e-4dbe-854a-4cf4b6da0e0e."
}

variable "target_type" {
  type        = string
  description = "The target type (either instances or window target ids).Valid values: InstanceIds, WindowTargetIds."
}

variable "task_arn" {
  type        = string
  description = "The ARN of the task to execute."
}

variable "task_type" {
  type        = string
  description = "The type of task being registered. Valid values: AUTOMATION, LAMBDA, RUN_COMMAND or STEP_FUNCTIONS."
}

variable "timeout_seconds" {
  type        = number
  description = "If this time is reached and the command has not already started executing, it doesn't run."
}

variable "window_id" {
  type        = string
  description = "The Id of the maintenance window to register the task with."
}
