include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../infrastructure-modules//helm"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}


dependencies {
  paths = ["../../eks/YOUR-PROJECT-NAME.env.eks",
    "../../kubernetes/namespace/argocd",
    "../env-argocd"
  ]
}

dependency "eks" {
  config_path = "../../eks/YOUR-PROJECT-NAME.env.eks"
  mock_outputs = {
    eks_cluster_id = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "namespace" {
  config_path = "../../kubernetes/namespace/argocd"
  mock_outputs = {
    namespace = ["k8s"]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  name = replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}")

  cluster_name         = dependency.eks.outputs.eks_cluster_id
  kubernetes_namespace = dependency.namespace.outputs.namespace[0]

  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argocd-apps"
  description   = "Argo CD Applications and Projects"
  chart_version = "2.0.1"

  reset_values = true
  reuse_values = true
  timeout      = 320
  values       = [file("./values.yaml")]
}
