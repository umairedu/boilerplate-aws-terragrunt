include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../../infrastructure-modules/kubernetes//namespace"
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
  paths = ["../../../eks/YOUR-PROJECT-NAME.env.eks"]
}

dependency "eks" {
  config_path = "../../../eks/YOUR-PROJECT-NAME.env.eks"
  mock_outputs = {
    eks_cluster_id = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  name         = "${basename(get_terragrunt_dir())}"
  cluster_name = dependency.eks.outputs.eks_cluster_id

}
