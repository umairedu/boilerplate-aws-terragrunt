include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}
terraform {
  source = "../../../../../../infrastructure-modules//codebuild"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}



inputs = {
  name               = replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}")
  environment        = ""
  build_image        = "aws/codebuild/amazonlinux2-x86_64-standard:corretto8"
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_timeout      = 60
  artifact_type      = "NO_ARTIFACTS"


  private_repository            = true
  source_credential_auth_type   = "PERSONAL_ACCESS_TOKEN"
  source_credential_server_type = "GITHUB"
  # Set environment variable: export YOUR-PROJECT-NAME_GITHUB_ACCESS_TOKEN=your-token
  source_credential_token = get_env("${include.root.locals.environment_vars.locals.project}_GITHUB_ACCESS_TOKEN")
  source_version          = "main"
  git_clone_depth         = "1"

  source_type       = "GITHUB"
  source_location   = "https://github.com/YOUR-GITHUB-ORG/YOUR-REPO-NAME.git" # Replace with your GitHub repository
  github_token      = "github_token"
  github_token_type = "SECRETS_MANAGER"

  privileged_mode = true
  buildspec       = "applications/core/buildspec.yml"

  filter_groups = [
    {
      filters = [
        {
          pattern = "PUSH"
          type    = "EVENT"
        },
        {
          pattern                 = "^refs/heads/main$"
          type                    = "HEAD_REF"
          exclude_matched_pattern = false
        },
        {
          pattern = "^applications/core/.*"
          type    = "FILE_PATH"
        }
      ]
    }
  ]

  environment_variables = [
    {
      name  = "APP_NAME"
      value = "${include.root.locals.environment_vars.locals.project}.${include.root.locals.env}.core"
      type  = "PLAINTEXT"
    },
    {
      name  = "REPOSITORY_URI"
      value = format("%s.dkr.ecr.%s.amazonaws.com", "${get_aws_account_id()}", "${include.root.locals.aws_region}")
      type  = "PLAINTEXT"
    }
  ]

  tags = merge(
    include.root.locals.base_tags,
  )

}
