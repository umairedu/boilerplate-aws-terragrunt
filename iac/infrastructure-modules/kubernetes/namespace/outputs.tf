output "namespace" {
  description = "All `kubernetes_namespace` resource attributes."
  value       = try(kubernetes_namespace.namespace.*.id, 0)
}

//output "kubeconfig" {
//  value = abspath("${path.root}/${local_file.kubeconfig.filename}")
//}