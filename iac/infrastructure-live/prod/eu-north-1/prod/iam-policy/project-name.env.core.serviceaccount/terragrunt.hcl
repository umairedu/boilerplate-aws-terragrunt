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

inputs = {
  name        = replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}")
  description = "Allow Core ServiceAccount to access AWS resources via Kubernetes serviceaccount"
  policy_statements = [
    {
      sid    = "VisualEditor0"
      effect = "Allow"
      actions = [
        "sqs:receivemessage",
        "sqs:deletemessage"
      ]
      resources = "*"
    },
    # Example: Add EventBridge permissions if needed
    # {
    #   sid    = "VisualEditor1"
    #   effect = "Allow"
    #   actions = [
    #     "events:PutEvents",
    #   ]
    #   resources = ["arn:aws:events:REGION:ACCOUNT-ID:event-bus/EVENT-BUS-NAME"]
    # }
  ]
  tags = merge(
    include.root.locals.base_tags,
  )

}
