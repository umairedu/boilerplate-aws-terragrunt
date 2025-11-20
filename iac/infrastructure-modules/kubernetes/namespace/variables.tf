variable "cluster_name" {
  type = string
}

variable "name" {
  description = "(Required) Name of the namespace, must be unique. Cannot be updated. For details please see https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names"
  type        = string
}

variable "labels" {
  description = "(Optional) Map of string keys and values that can be used to organize and categorize (scope and select) namespaces. May match selectors of replication controllers and services."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "(Optional) An unstructured key value map stored with the namespace that may be used to store arbitrary metadata."
  type        = map(string)
  default     = {}
}