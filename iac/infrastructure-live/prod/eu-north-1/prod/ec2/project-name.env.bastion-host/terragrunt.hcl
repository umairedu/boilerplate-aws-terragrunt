include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "tfr:///terraform-aws-modules/ec2-instance/aws//.?version=5.7.0"

  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}

dependencies {
  paths = ["../../vpc/YOUR-PROJECT-NAME.env.vpc/",
    "../../datasources/",
    "../../security-groups/YOUR-PROJECT-NAME.env.ec2.bastion-host",
    "../../keypair/YOUR-PROJECT-NAME.env.bastion-host"
  ]
}


dependency "datasources" {
  config_path = "../../datasources/"
  mock_outputs = {
    ubuntu_1804_aws_ami_id = "ami-08d658f84a6d84a80"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]

}

dependency "vpc" {
  config_path = "../../vpc/YOUR-PROJECT-NAME.env.vpc/"
  mock_outputs = {
    vpc_id         = "vpc-0557d70b7766b7799"
    public_subnets = ["subnet-0d8ff9627adc20aca", "subnet-0d8ff9627adc20acb"]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]

}

dependency "bastion_host_sg" {
  config_path = "../../security-groups/YOUR-PROJECT-NAME.env.ec2.bastion-host"
  mock_outputs = {
    security_group_id = "87c6c06"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "bastion_host_keypair" {
  config_path = "../../keypair/YOUR-PROJECT-NAME.env.bastion-host"
  mock_outputs = {
    key_pair_name = "my-fake-key"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  name                        = replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}")
  team                        = "${include.root.locals.environment_vars.locals.team}"
  project                     = "${include.root.locals.environment_vars.locals.project}"
  env                         = "${include.root.locals.env}"
  ami                         = "ami-09ea76417bee71eaa"
  vpc_security_group_ids      = [dependency.bastion_host_sg.outputs.security_group_id]
  subnet_ids                  = [dependency.vpc.outputs.public_subnets[0]]
  key_name                    = dependency.bastion_host_keypair.outputs.key_pair_name
  instance_count              = 1
  instance_type               = "${include.root.locals.environment_vars.locals.bastion_host_instance_type}"
  disable_api_termination     = true
  monitoring                  = false
  tenancy                     = "default"
  assign_eip_address          = true
  associate_public_ip_address = true
  disk_size                   = 20
  ebs_optimized               = false
  ebs_volume_enabled          = true
  ebs_volume_type             = "gp2"
  ebs_volume_size             = 25
  user_data                   = "install_package.sh"

  tags = merge(
    {
      name = replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}")
    },
    include.root.locals.base_tags,
  )

}
