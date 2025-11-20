include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../../infrastructure-modules/kubernetes//serviceaccount"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}


include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../../../eks/YOUR-PROJECT-NAME.env.eks",
    "../../../iam-role/YOUR-PROJECT-NAME.env.autoscaler.serviceaccount"
  ]
}

dependency "eks" {
  config_path = "../../../eks/YOUR-PROJECT-NAME.env.eks"
  mock_outputs = {
    eks_cluster_id = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "iam_service_account_role_autoscaler" {
  config_path = "../../../iam-role/YOUR-PROJECT-NAME.env.autoscaler.serviceaccount"
  mock_outputs = {
    iam_role_arn = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  name                            = "${basename(get_terragrunt_dir())}"
  namespace                       = "kube-system"
  automount_service_account_token = true
  cluster_name                    = dependency.eks.outputs.eks_cluster_id

  labels = {
    "app.kubernetes.io/name" = "cluster-autoscaler"
  }
  annotations = {
    "eks.amazonaws.com/role-arn" = dependency.iam_service_account_role_autoscaler.outputs.iam_role_arn
  }

}
