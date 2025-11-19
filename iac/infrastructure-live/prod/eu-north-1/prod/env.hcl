# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment                = "prod"
  team                       = "DevOps"            # Replace with your team name
  project                    = "YOUR-PROJECT-NAME" # Replace with your project name
  cidr                       = "10.9.0.0/16"       # Replace with your VPC CIDR block
  bastion_host_instance_type = "t3.nano"
}
