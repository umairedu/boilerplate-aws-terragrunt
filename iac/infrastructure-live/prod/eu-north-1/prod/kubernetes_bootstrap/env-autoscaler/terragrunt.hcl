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
  paths = ["../../eks/YOUR-PROJECT-NAME.env.eks"
  ]
}

dependency "eks" {
  config_path = "../../eks/YOUR-PROJECT-NAME.env.eks"
  mock_outputs = {
    eks_cluster_id = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}



inputs = {
  name = replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}")

  cluster_name         = dependency.eks.outputs.eks_cluster_id
  kubernetes_namespace = "kube-system"

  repository    = "https://kubernetes.github.io/autoscaler"
  chart         = "cluster-autoscaler"
  description   = "Scales Kubernetes worker nodes within autoscaling groups"
  chart_version = "9.40.0"

  reset_values = true
  reuse_values = true
  timeout      = 320


  set = [
    {
      name  = "autoDiscovery.clusterName"
      value = dependency.eks.outputs.eks_cluster_id
      type  = "string"
    },

    {
      name  = "awsRegion"
      value = "${include.root.locals.aws_region}"
      type  = "string"
    },

    {
      name  = "rbac.serviceAccount.create"
      value = false
      type  = "auto"
    },

    {
      name  = "rbac.serviceAccount.name"
      value = "${include.root.locals.environment_vars.locals.project}-${include.root.locals.env}-cluster-autoscaler"
      type  = "string"
    }
  ]


}