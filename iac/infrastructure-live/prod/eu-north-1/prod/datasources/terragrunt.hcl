include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../infrastructure-modules//datasources"
}

inputs = {
  acm_domain = "*.YOUR-DOMAIN.com" # Replace with your domain name (e.g., *.example.com)
}
