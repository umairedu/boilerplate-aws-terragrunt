include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws//.?version=5.2.0"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}
dependency "vpc" {
  config_path = "../../vpc/YOUR-PROJECT-NAME.env.vpc"
  mock_outputs = {
    vpc_id = "vpc-0557d70b7766b7799"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  name                = replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}")
  description         = "Security group to allow public SSH and VPN traffic"
  vpc_id              = dependency.vpc.outputs.vpc_id
  team                = "${include.root.locals.environment_vars.locals.team}"
  project             = "${include.root.locals.environment_vars.locals.project}"
  env                 = "${include.root.locals.env}"
  ingress_cidr_blocks = ["${include.root.locals.environment_vars.locals.cidr}"]
  ingress_rules       = ["ssh-tcp"]
  ingress_with_cidr_blocks = [
    {
      rule        = "openvpn-udp"
      cidr_blocks = "0.0.0.0/0",
      description = "Allow openvpn traffic"
    },
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]



  tags = merge(
    {
      name = replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}")
    },
    include.root.locals.base_tags,
  )
}
