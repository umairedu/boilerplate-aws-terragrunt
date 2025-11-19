include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "git@github.com:cloudposse/terraform-aws-kms-key.git//.?ref=0.12.1"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}


inputs = {
  description             = "Helm secrets for ${include.root.locals.environment_vars.locals.project} Apps"
  deletion_window_in_days = 20
  enable_key_rotation     = false
  alias                   = format("alias/%s", replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}"))
  tags = merge(
    {
      name = replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}")
    },
    include.root.locals.base_tags,
  )

}
