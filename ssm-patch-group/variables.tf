variable "baseline_id" {
  type        = string
  description = "The ID of the patch baseline to register the patch group with."
}

variable "patch_group" {
  type        = string
  description = "The name of the patch group that should be registered with the patch baseline."
}
