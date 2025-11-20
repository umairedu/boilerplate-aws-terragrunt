include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}
terraform {
  source = "git::https://github.com/mineiros-io/terraform-aws-iam-policy.git//?ref=v0.5.2"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}

dependencies {
  paths = ["../../kms/YOUR-PROJECT-NAME_env_app_secrets"]
}

dependency "kms_arn" {
  config_path = "../../kms/YOUR-PROJECT-NAME_env_app_secrets"
  mock_outputs = {
    alias_arn = "XXXXXXXXXX"
    key_arn   = "XXXXXXXXXX"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  name        = replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}")
  description = "Allows ArgoCD to Decrypt/Encrypt app secrets"
  policy_statements = [
    {
      sid    = "ArgoCDKMS"
      effect = "Allow"
      actions = [
        "kms:Decrypt*",
        "kms:Encrypt*",
        "kms:GenerateDataKey",
        "kms:ReEncrypt*",
        "kms:DescribeKey",
      ]
      resources = [dependency.kms_arn.outputs.key_arn
      ]
    }
  ]
  tags = merge(
    include.root.locals.base_tags,
  )

}
