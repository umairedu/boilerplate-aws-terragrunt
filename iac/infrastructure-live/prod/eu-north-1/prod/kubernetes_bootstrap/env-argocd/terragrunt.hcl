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
    "../../iam-role/YOUR-PROJECT-NAME.env.argocd.serviceaccount"
  ]
}

dependency "eks" {
  config_path = "../../eks/YOUR-PROJECT-NAME.env.eks"
  mock_outputs = {
    eks_cluster_id = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "service_account_role" {
  config_path = "../../iam-role/YOUR-PROJECT-NAME.env.argocd.serviceaccount"
  mock_outputs = {
    iam_role_arn = "arn"
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
  chart         = "argo-cd"
  description   = "GitOps continuous delivery tool for Kubernetes"
  chart_version = "9.0.3"

  reset_values = true
  reuse_values = true
  timeout      = 320
  values       = [file("./values.yaml")]

  set = [
    {
      name  = "configs.repositories.private-helm-repo.password"
      value = get_env("${upper(replace(include.root.locals.environment_vars.locals.project, "-", "_"))}_GITHUB_ACCESS_TOKEN")
      type  = "string"
    },
    {
      name  = "repoServer.serviceAccount.create"
      value = true
      type  = "auto"
    },
    {
      name  = "repoServer.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = dependency.service_account_role.outputs.iam_role_arn
      type  = "string"
    },
    {
      name  = "repoServer.serviceAccount.name"
      value = "${include.root.locals.environment_vars.locals.project}-${include.root.locals.env}-argocd-repo-server"
      type  = "auto"
    },
    {
      name  = "repoServer.serviceAccount.automountServiceAccountToken"
      value = true
      type  = "auto"
    }
  ]


}