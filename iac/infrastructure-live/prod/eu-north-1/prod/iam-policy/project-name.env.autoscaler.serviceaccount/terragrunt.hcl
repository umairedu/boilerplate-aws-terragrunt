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
  description = "Allows Autoscaler to add remove EKS nodes"
  policy_statements = [
    {
      sid    = "AllowToScaleEKSNodeGroupAutoScalingGroup"
      effect = "Allow"
      actions = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions",
        "rds:AddTagsToResource",
      ]
      resources = ["*"]
    }
  ]
  tags = merge(
    include.root.locals.base_tags,
  )

}
