terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.39.0"
    }
  }
  required_version = ">= 1.9.0"
}
