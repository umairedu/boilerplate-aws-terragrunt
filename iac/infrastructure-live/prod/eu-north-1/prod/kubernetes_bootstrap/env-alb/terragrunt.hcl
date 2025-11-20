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
    "../../iam-role/YOUR-PROJECT-NAME.env.eks.serviceaccounts",
    "../../vpc/YOUR-PROJECT-NAME.env.vpc/"
  ]
}


dependency "vpc" {
  config_path = "../../vpc/YOUR-PROJECT-NAME.env.vpc/"
  mock_outputs = {
    vpc_id         = "vpc-0557d70b7766b7799"
    public_subnets = ["subnet-0d8ff9627adc20aca", "subnet-0d8ff9627adc20acb"]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]

}

dependency "eks" {
  config_path = "../../eks/YOUR-PROJECT-NAME.env.eks"
  mock_outputs = {
    eks_cluster_id = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  cluster_name = dependency.eks.outputs.eks_cluster_id

  name                 = "aws-load-balancer-controller"
  kubernetes_namespace = "kube-system"

  repository    = "https://aws.github.io/eks-charts"
  chart         = "aws-load-balancer-controller"
  description   = "AWS Load Balancer Controller for Kubernetes"
  chart_version = "1.8.3"

  reset_values = true
  reuse_values = true
  timeout      = 120
  values       = [file("./values.yaml")]

  set = [
    {
      name  = "region"
      value = "${include.root.locals.aws_region}"
      type  = "string"
    },

    {
      name  = "replicaCount"
      value = 2
      type  = "auto"
    },

    {
      name  = "vpcId"
      value = dependency.vpc.outputs.vpc_id
      type  = "string"
    },

    {
      name  = "serviceAccount.create"
      value = false
      type  = "auto"
    },

    {
      name  = "serviceAccount.name"
      value = "${include.root.locals.environment_vars.locals.project}-${include.root.locals.env}-aws-load-balancer-controller"
      type  = "string"
    },

    {
      name  = "clusterName"
      value = dependency.eks.outputs.eks_cluster_id
      type  = "string"
    }
  ]


}



