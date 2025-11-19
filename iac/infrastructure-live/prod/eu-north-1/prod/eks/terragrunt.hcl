include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "tfr:///cloudposse/eks-cluster/aws//.?version=4.4.0"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}

dependencies {
  paths = ["../../vpc/YOUR-PROJECT-NAME.env.vpc/", "../../datasources"]
}


dependency "aws-data" {
  config_path = "../../datasources"
  mock_outputs = {
    issuer_arn = "blalblabla"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}


dependency "vpc" {
  config_path = "../../vpc/YOUR-PROJECT-NAME.env.vpc/"
  mock_outputs = {
    vpc_id         = "vpc-0557d70b7766b7799"
    public_subnets = ["subnet-0d8ff9627adc20aca", "subnet-0d8ff9627adc20acb"]
    vpc_cidr_block = "10.29.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}



inputs = {
  name                              = replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}")
  region                            = "${include.root.locals.aws_region}"
  vpc_id                            = dependency.vpc.outputs.vpc_id
  subnet_ids                        = dependency.vpc.outputs.public_subnets
  kubernetes_version                = "1.31"
  oidc_provider_enabled             = true
  enabled_cluster_log_types         = ["audit", "authenticator"]
  cluster_log_retention_period      = 7
  cluster_encryption_config_enabled = false
  environment                       = ""
  endpoint_public_access            = true

  access_entry_map = {
    (dependency.aws-data.outputs.issuer_arn) = {
      access_policy_associations = {
        ClusterAdmin = {}
      }
    },
    # Example: Add your IAM user ARN for cluster access
    # "arn:aws:iam::YOUR-AWS-ACCOUNT-ID:user/YOUR-USERNAME" = {
    #   access_policy_associations = {
    #     ClusterAdmin = {}
    #   }
    # }
  }

  access_config = {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }


  tags = merge(
    include.root.locals.base_tags,
  )

}