variable "approve_after_days" {
  type        = number
  description = "The number of days after the release date of each patch matched by the rule the patch is marked as approved in the patch baseline. Valid Range: 0 to 100. Conflicts with approve_until_date"
  default     = 1
}

variable "approved_patches" {
  type        = string
  description = "A list of explicitly approved patches for the baseline."
  default     = ""
}

variable "approved_patches_compliance_level" {
  type        = string
  description = "Defines the compliance level for approved patches. This means that if an approved patch is reported as missing, this is the severity of the compliance violation. Valid compliance levels include the following: CRITICAL, HIGH, MEDIUM, LOW, INFORMATIONAL, UNSPECIFIED. The default value is UNSPECIFIED."
  default     = ""
}

variable "approved_patches_enable_non_security" {
  type        = string
  description = "Indicates whether the list of approved patches includes non-security updates that should be applied to the instances. Applies to Linux instances only."
  default     = ""
}

variable "approve_until_date" {
  type        = string
  description = "The cutoff date for auto approval of released patches. Any patches released on or before this date are installed automatically. Date is formatted as YYYY-MM-DD. Conflicts with approve_after_days"
  default     = ""
}

variable "compliance_level" {
  type        = string
  description = "Defines the compliance level for patches approved by this rule. Valid compliance levels include the following: CRITICAL, HIGH, MEDIUM, LOW, INFORMATIONAL, UNSPECIFIED. The default value is UNSPECIFIED."
  default     = "UNSPECIFIED"
}

variable "configuration" {
  type        = string
  description = "The value of the yum repo configuration. For information about other options available for your yum repository configuration, see the dnf.conf documentation"
  default     = ""
}

variable "description" {
  type        = string
  description = "The description of the patch baseline."
  default     = ""
}

variable "enable_non_security" {
  type        = bool
  description = "Boolean enabling the application of non-security updates. The default value is 'false'. Valid for Linux instances only."
  default     = false
}

variable "global_filter" {
  type        = string
  description = "A set of global filters used to exclude patches from the baseline. Up to 4 global filters can be specified using Key/Value pairs. Valid Keys are PRODUCT | CLASSIFICATION | MSRC_SEVERITY | PATCH_ID."
  default     = ""
}

variable "name" {
  type        = string
  description = "The name of the patch baseline."
}

variable "operating_system" {
  type        = string
  description = "Defines the operating system the patch baseline applies to. Supported operating systems include WINDOWS, AMAZON_LINUX, AMAZON_LINUX_2, SUSE, UBUNTU, CENTOS, and REDHAT_ENTERPRISE_LINUX."
  default     = "AMAZON_LINUX_2"
}

variable "patch_filter" {
  type        = string
  description = "The patch filter group that defines the criteria for the rule. Up to 5 patch filters can be specified per approval rule using Key/Value pairs. Valid combinations of these Keys and the operating_system value can be found in the SSM DescribePatchProperties API Reference. Valid Values are exact values for the patch property given as the key, or a wildcard *, which matches all values. PATCH_SET defaults to OS if unspecified"
  default     = ""
}

variable "products" {
  type        = string
  description = "The specific operating system versions a patch repository applies to, such as "Ubuntu16.04", "AmazonLinux2016.09", "RedhatEnterpriseLinux7.2" or "Suse12.7". For lists of supported product values, see PatchFilter."
  default     = ""
}

variable "rejected_patches" {
  type        = string
  description = "A list of rejected patches."
  default     = ""
}

variable "rejected_patches_action" {
  type        = string
  description = "The action for Patch Manager to take on patches included in the rejected_patches list. Allow values are ALLOW_AS_DEPENDENCY and BLOCK."
  default     = ""
}

variable "source" {
  type        = string
  description = "The name specified to identify the patch source."
  default     = ""
}

variable "tags" {
  type        = map
  description = "A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default     = {
    "" = ""
  }
}
