# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "prod"
  aws_account_id = "YOUR-AWS-ACCOUNT-ID" # Replace with your AWS account ID
  aws_profile    = "prod"                # Replace with your AWS profile name
}
