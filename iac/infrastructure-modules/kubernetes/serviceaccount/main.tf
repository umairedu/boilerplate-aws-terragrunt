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

resource "kubernetes_service_account" "service_account" {

  metadata {
    name        = var.name
    namespace   = var.namespace
    labels      = var.labels
    annotations = var.annotations
  }
  automount_service_account_token = var.automount_service_account_token
}