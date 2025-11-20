data "aws_eks_cluster" "default" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

provider "helm" {
  # Helm provider v2.x automatically uses the kubernetes provider configuration
  # No nested kubernetes block needed
}


resource "helm_release" "default" {
  name        = var.name
  chart       = var.chart
  description = var.description
  version     = var.chart_version

  repository = var.repository
  namespace  = var.kubernetes_namespace


  reset_values = var.reset_values
  reuse_values = var.reuse_values
  timeout      = var.timeout
  values       = var.values
  wait         = var.wait


  dynamic "set" {
    for_each = var.set
    iterator = item
    content {
      name  = item.value.name
      value = item.value.value
      type  = item.value.type
    }
  }

  dynamic "set_sensitive" {
    for_each = var.set_sensitive
    iterator = item
    content {
      name  = item.value.name
      value = item.value.value
      type  = item.value.type
    }
  }

}