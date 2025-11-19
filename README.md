# AWS Kubernetes Infrastructure Boilerplate with Terragrunt

> **Boilerplate for deploying infrastructure and applications on AWS EKS using Terragrunt, Helm, and ArgoCD.**

## Intro

This boilerplate provides a complete foundation for deploying and managing infrastructure and containerized applications on AWS.

### Key Features

- **Infrastructure as Code**: Complete AWS infrastructure setup using Terragrunt (VPC, EKS, EC2, IAM, KMS, ECR, etc.)
- **Kubernetes-Ready**: Generic Helm chart for deploying any containerized application
- **GitOps Integration**: ArgoCD support for automated deployments
- **Security First**: KMS encryption, SOPS for secrets management, RBAC, and security best practices
- **CI/CD Ready**: AWS CodeBuild integration for automated builds and deployments
- **Multi-Environment**: Support for multiple environments (production, staging, etc.)
- **Best Practices**: Follows AWS Well-Architected Framework principles

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Infrastructure Deployment](#infrastructure-deployment)
- [Application Deployment](#application-deployment)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have the following tools installed:

| Tool | Purpose | Installation |
|------|---------|--------------|
| [Tgswitch](https://github.com/warrensbox/tgswitch/) | Terragrunt version manager | See [installation guide](https://github.com/warrensbox/tgswitch/) |
| [Tfenv](https://github.com/tfutils/tfenv/) | Terraform version manager | See [installation guide](https://github.com/tfutils/tfenv/) |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) | AWS service interaction | `brew install awscli` (macOS) or [official guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Kubernetes cluster management | `brew install kubectl` (macOS) or [official guide](https://kubernetes.io/docs/tasks/tools/) |
| [Helm](https://helm.sh/docs/intro/install/) | Kubernetes package manager | `brew install helm` (macOS) or [official guide](https://helm.sh/docs/intro/install/) |
| [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) | ArgoCD command-line tool | See [installation guide](https://argo-cd.readthedocs.io/en/stable/cli_installation/) |
| [Pre-commit](https://pre-commit.com/) | Git hooks for code quality | `brew install pre-commit` (macOS) or `pip install pre-commit` |
| [SOPS](https://github.com/mozilla/sops) | Secrets management | `brew install sops` (macOS) or [official guide](https://github.com/mozilla/sops) |

### AWS Account Setup

1. **Configure AWS Credentials**:
   ```bash
   aws configure
   ```
   Provide your AWS access key, secret access key, default region, and output format.

2. **Verify Access**:
   ```bash
   aws sts get-caller-identity
   ```

3. **Required Permissions**: Your AWS credentials should have permissions to create:
   - VPCs, Subnets, Internet Gateways, NAT Gateways
   - EKS Clusters and Node Groups
   - EC2 Instances, Security Groups, Key Pairs
   - IAM Roles and Policies
   - ECR Repositories
   - KMS Keys
   - S3 Buckets (for Terraform state)
   - DynamoDB Tables (for state locking)

## Getting Started

### 1. Clone the Repository

```bash
git clone git@github.com:umairedu/boilerplate-aws-terragrunt.git
cd boilerplate-aws-terragrunt
```

### 2. Initialize Pre-commit Hooks

```bash
pre-commit install
```

## Configuration & Setup

Before deploying, you need to configure the boilerplate for your project. This section covers all the necessary steps.

### Step 1: Replace Placeholders

The boilerplate uses placeholders that must be replaced with your actual values:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `YOUR-PROJECT-NAME` | Your project name | `my-awesome-app` |
| `YOUR-AWS-ACCOUNT-ID` | Your AWS account ID (12 digits) | `123456789012` |
| `YOUR-AWS-REGION` | Your AWS region | `eu-north-1`, `us-east-1` |
| `YOUR-DOMAIN.com` | Your domain name | `example.com` |
| `YOUR-GITHUB-ORG/YOUR-REPO-NAME` | Your GitHub organization and repository | `my-org/my-repo` |
| `YOUR-APP-NAME` | Your application name | `my-app` |

### Step 2: Update Configuration Files

#### Account Configuration (`iac/infrastructure-live/prod/account.hcl`)

```hcl
locals {
  account_name   = "prod"
  aws_account_id = "123456789012"   # Replace with your AWS account ID
  aws_profile    = "prod"           # Replace with your AWS profile name
}
```

#### Environment Configuration (`iac/infrastructure-live/prod/eu-north-1/prod/env.hcl`)

```hcl
locals {
  environment                = "prod"
  team                       = "DevOps"              # Replace with your team name
  project                    = "my-awesome-app"      # Replace with your project name
  cidr                       = "10.9.0.0/16"         # Replace with your VPC CIDR block
  bastion_host_instance_type = "t3.nano"
}
```

#### SOPS Configuration (`kubernetes/.sops.yaml`)

```yaml
creation_rules:
  - path_regex: 'charts\/.*\/production\/(.*).yaml'
    # Replace with your KMS key ARN (created after KMS module deployment)
    kms: 'arn:aws:kms:eu-north-1:123456789012:alias/my-awesome-app_prod_app_secrets'
```

**Note**: The KMS key ARN will be available after deploying the KMS module. You can update this file after the first infrastructure deployment.

#### Domain Configuration (`iac/infrastructure-live/prod/eu-north-1/prod/datasources/terragrunt.hcl`)

```hcl
inputs = {
  acm_domain = "*.example.com"  # Replace with your domain name
}
```

### Step 3: Rename Directories

After setting `YOUR-PROJECT-NAME` in `env.hcl`, rename directories to match your project name pattern:

```bash
# Example: If YOUR-PROJECT-NAME is "my-awesome-app"
cd iac/infrastructure-live/prod/eu-north-1/prod

# Rename directories (replace 'my-awesome-app' with your actual project name)
mv vpc/project-name.env.vpc vpc/my-awesome-app.env.vpc
mv ec2/project-name.env.bastion-host ec2/my-awesome-app.env.bastion-host
mv ecr/project-name.env.core ecr/my-awesome-app.env.core
mv eks/project-name.env.eks eks/my-awesome-app.env.eks
mv eks/project-name.env-eks-node-group-v1 eks/my-awesome-app.env-eks-node-group-v1
mv kms/project-name_env_app_secrets kms/my-awesome-app_env_app_secrets
mv security-groups/project-name.env.ec2.bastion-host security-groups/my-awesome-app.env.ec2.bastion-host
mv keypair/project-name.env.bastion-host keypair/my-awesome-app.env.bastion-host
mv codebuild/project-name-env-core codebuild/my-awesome-app-env-core
mv iam-group/project-name.env.devops iam-group/my-awesome-app.env.devops
```

**Important**: Directory names use the `.env.` pattern. If your project name is `my-awesome-app`, directories will be `my-awesome-app.env.vpc`, `my-awesome-app.env.eks`, etc.

### Step 4: Set Environment Variables

Some configurations require environment variables:

```bash
# GitHub token for CodeBuild (replace YOUR-PROJECT-NAME with your actual project name)
export YOUR-PROJECT-NAME_GITHUB_ACCESS_TOKEN=your-github-token-here

# Example: If project name is "my-awesome-app"
export my-awesome-app_GITHUB_ACCESS_TOKEN=ghp_xxxxxxxxxxxx
```

### Step 5: Update CodeBuild Configuration

Edit `iac/infrastructure-live/prod/eu-north-1/prod/codebuild/YOUR-PROJECT-NAME-env-core/terragrunt.hcl`:

```hcl
source_location = "https://github.com/umairedu/boilerplate-aws-terragrunt.git"  # Replace with your repository
```

## Quick Start

After completing the [Configuration & Setup](#configuration--setup) steps above, follow these steps to deploy your infrastructure:

### 1. Deploy Infrastructure

```bash
cd iac/infrastructure-live/prod/eu-north-1/prod
terragrunt run-all init
terragrunt run-all plan
terragrunt run-all apply
```

This will deploy:
- VPC with subnets
- EKS cluster and node groups
- EC2 bastion host
- ECR repositories
- KMS keys
- Security groups
- IAM roles and policies
- CodeBuild project

### 2. Configure Kubernetes Access

```bash
# Get your cluster name from the EKS output
# The cluster name follows the pattern: YOUR-PROJECT-NAME-prod-eks
aws eks --region eu-north-1 update-kubeconfig --name <your-cluster-name>
kubectl get nodes
```

### 3. Deploy Your First Application

```bash
cd kubernetes/charts/generic-chart
helm install my-app . -f core/production/values.yaml
```

### 4. Verify Deployment

```bash
# Check pods
kubectl get pods

# Check services
kubectl get svc

# Check ingress (if configured)
kubectl get ingress
```

## Project Structure

```
boilerplate-aws-terragrunt/
├── iac/
│   ├── infrastructure-live/          # Terragrunt live configurations
│   │   └── prod/
│   │       ├── account.hcl          # Account-level configuration
│   │       ├── terragrunt.hcl       # Root Terragrunt config
│   │       └── eu-north-1/
│   │           ├── region.hcl       # Region configuration
│   │           └── prod/
│   │               ├── env.hcl      # Environment configuration
│   │               ├── vpc/          # VPC infrastructure
│   │               ├── eks/          # EKS cluster and node groups
│   │               ├── ec2/         # EC2 instances (bastion host)
│   │               ├── ecr/         # Container registries
│   │               ├── kms/         # KMS keys for encryption
│   │               ├── iam-group/   # IAM groups and roles
│   │               ├── security-groups/  # Security groups
│   │               ├── secrets-manager/  # AWS Secrets Manager
│   │               ├── codebuild/   # CI/CD pipelines
│   │               └── datasources/     # AWS data sources
│   └── infrastructure-modules/     # Reusable Terraform modules
│       ├── codebuild/               # CodeBuild module
│       └── datasources/             # Data sources module
├── kubernetes/
│   └── .sops.yaml                   # SOPS encryption configuration
│   └── charts/
│       └── generic-chart/           # Generic Helm chart
│           ├── Chart.yaml
│           ├── values.yaml          # Default values
│           ├── core/
│           │   ├── production/      # Production environment values
│           │   └── staging/         # Staging environment values
│           └── templates/           # Kubernetes manifests
│               ├── deployment.yaml
│               ├── service.yaml
│               ├── ingress.yaml
│               ├── configmap.yaml
│               ├── secret.yaml
│               └── ...
├── .pre-commit-config.yaml          # Pre-commit hooks
├── .tflint.hcl                      # Terraform linting config
└── README.md                        # This file
```

## Infrastructure Deployment

### Understanding Terragrunt Configuration

This project uses a hierarchical Terragrunt configuration structure:

- **`account.hcl`**: Account-wide settings (account ID, profile)
- **`region.hcl`**: Region-specific settings
- **`env.hcl`**: Environment-specific settings (project name, CIDR, etc.)
- **`terragrunt.hcl`**: Root configuration that merges all settings

### Deployment Steps

1. **Review Configuration**:
   ```bash
   # Check your account configuration
   cat iac/infrastructure-live/prod/account.hcl
   
   # Review environment settings
   cat iac/infrastructure-live/prod/eu-north-1/prod/env.hcl
   ```

2. **Initialize Terragrunt**:
   ```bash
   cd iac/infrastructure-live/prod/eu-north-1/prod
   terragrunt run-all init
   ```

3. **Plan Changes**:
   ```bash
   terragrunt run-all plan
   ```

4. **Apply Infrastructure**:
   ```bash
   terragrunt run-all apply
   ```

### Infrastructure Components

#### VPC
- Multi-AZ VPC with public, private, and database subnets
- NAT Gateway for outbound internet access
- DNS support enabled

#### EKS Cluster
- **Kubernetes Version**: 1.31
- **OIDC Provider**: Enabled for IRSA (IAM Roles for Service Accounts)
- **Cluster Logging**: Audit and authenticator logs enabled
- **Endpoint Access**: Public endpoint access enabled
- **Authentication**: API mode with access entries
- **Node Groups**: Auto-scaling node groups (1-15 nodes) with spot instances
- **Features**: Cluster autoscaler, EBS encryption, ECR and EBS CSI driver policies

#### EC2 Bastion Host
- Secure jump host for accessing private resources
- Elastic IP address
- Security group with restricted access

#### ECR Repositories
- Private Docker image repositories
- Lifecycle policies for image retention

#### KMS Keys
- Encryption keys for application secrets
- Used with SOPS for secret management

## Application Deployment

### Using the Generic Helm Chart

The included Helm chart is designed to be flexible and work with any containerized application.

#### 1. Configure Your Application

Edit the values file for your environment:

```bash
vim kubernetes/charts/generic-chart/core/production/values.yaml
```

Key configuration areas:
- **Image**: Container image repository and tag
- **Resources**: CPU and memory limits/requests
- **Replicas**: Number of pod replicas
- **Environment Variables**: Application configuration
- **Service**: Service type and ports
- **Ingress**: External access configuration
- **RBAC**: Service accounts and permissions

#### 2. Deploy with Helm

```bash
cd kubernetes/charts/generic-chart
helm install my-application . -f core/production/values.yaml
```

#### 3. Verify Deployment

```bash
kubectl get pods -l app=my-application
kubectl get svc my-application
```

### ArgoCD Integration

For GitOps deployments, configure ArgoCD to sync from your Git repository:

1. **Install ArgoCD** (if not already installed):
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. **Access ArgoCD UI**:
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```
   Access at `https://localhost:8080`

3. **Get Admin Password**:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

4. **Create Application**:
   Use the ArgoCD UI or CLI to create an application pointing to your Helm chart repository.

### Secrets Management

This boilerplate uses **SOPS** (Secrets Operations) with AWS KMS for encrypting sensitive values:

1. **Install SOPS** (if not already installed):
   ```bash
   brew install sops
   ```

2. **Encrypt Secrets**:
   ```bash
   sops -e -i kubernetes/charts/generic-chart/core/production/values-enc.yaml
   ```

3. **Configure SOPS**:
   The `kubernetes/.sops.yaml` file defines encryption rules based on file paths. Update the KMS ARN after deploying the KMS module.

## Best Practices

### Infrastructure

1. **State Management**: Terraform state is stored in S3 with DynamoDB locking
2. **Version Control**: Use version pinning for all Terraform modules
3. **Tagging**: Consistent tagging strategy for all resources
4. **Least Privilege**: IAM roles follow the principle of least privilege
5. **Encryption**: All secrets encrypted at rest using KMS

### Kubernetes

1. **Resource Limits**: Always set CPU and memory limits
2. **Health Checks**: Configure readiness and liveness probes
3. **Security Context**: Run containers as non-root users
4. **RBAC**: Use service accounts with minimal required permissions
5. **Pod Disruption Budgets**: Ensure high availability during updates

### CI/CD

1. **Build Caching**: Use S3 cache for CodeBuild to speed up builds
2. **Image Tagging**: Use semantic versioning for container images
3. **Automated Testing**: Run tests in CI pipeline before deployment
4. **GitOps**: Use ArgoCD for declarative application management

## Troubleshooting

#### Terragrunt State Lock

If you encounter a state lock error:

```bash
# Check for locks in DynamoDB
aws dynamodb scan --table-name terraform-locks

# Force unlock (use with caution)
terragrunt force-unlock <lock-id>
```

#### Helm Deployment Failures

```bash
# Check pod status
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>

# Check Helm release status
helm status <release-name>
```
#### KMS Key Not Found

Make sure the KMS key ARN in `kubernetes/.sops.yaml` matches the key created by the KMS module. You can get the key ARN after deploying the KMS infrastructure.

### Useful Commands

```bash
# Terragrunt aliases (add to your ~/.zshrc or ~/.bashrc)
alias tia='terragrunt run-all init -reconfigure --terragrunt-non-interactive'
alias tpa='terragrunt run-all plan --terragrunt-non-interactive'
alias taa='terragrunt run-all apply --terragrunt-non-interactive -auto-approve'

# ArgoCD shortcuts
alias argop='kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d'
alias argof='kubectl port-forward service/argocd-server -n argocd 8080:443'
```
---

If you find this boilerplate useful, please give it a ⭐ on GitHub!
