variable "cluster_name" {
  type = string
}

variable "name" {
  type        = string
  description = "(String) Release name. The length must not be longer than 53 characters."
}

variable "chart" {
  type        = string
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended."
  default     = ""
}

variable "release_name" {
  type        = string
  description = "The name of the release to be installed. If omitted, use the name input, and if that's omitted, use the chart input."
  default     = ""
}

variable "description" {
  type        = string
  description = "Release description attribute (visible in the history)."
  default     = null
}
variable "repository" {
  type        = string
  description = "Repository URL where to locate the requested chart."
  default     = null
}
variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  default     = null
}
variable "kubernetes_namespace" {
  type        = string
  description = "The namespace to install the release into. Defaults to `default`."
  default     = null
}

variable "reset_values" {
  type        = bool
  description = "When upgrading, reset the values to the ones built into the chart. Defaults to `false`."
  default     = null
}

variable "reuse_values" {
  type        = bool
  description = "When upgrading, reuse the last release's values and merge in any overrides. If `reset_values` is specified, this is ignored. Defaults to `false`."
  default     = null
}
variable "timeout" {
  type        = number
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds."
  default     = null
}

variable "values" {
  type        = any
  description = "List of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple `-f` options."
  default     = null
}
variable "wait" {
  type        = bool
  description = "Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`."
  default     = null
}
variable "set" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  description = "Value block with custom values to be merged with the values yaml."
  default     = []
}

variable "set_sensitive" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  description = "Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff."
  default     = []
}
