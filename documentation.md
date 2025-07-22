Documentation: Automated Application & Database Deployment Solution


Last Updated: 22 July 2025
Owner: Yakub Badmus-Ola
1. Executive Summary

This document outlines a secure, automated, and multi-environment solution for deploying an application and its dedicated database on a Kubernetes cluster. The solution is implemented as a GitHub Actions CI/CD workflow, leveraging Terraform for infrastructure-as-code and Helm for Kubernetes package management.

The architecture is designed with security as a priority, integrating with AWS Secrets Manager and the Secrets Store CSI Driver to eliminate plaintext credentials from the deployment pipeline. It fully respects the existing network constraints, including an Istio service mesh with a REGISTRY_ONLY outbound traffic policy and the requirement to deploy the database into a pre-existing private subnet.

Key Benefits:

    Fully Automated via GitHub Actions: Single-click, auditable deployment for any target environment.

    Secure by Design: Uses OIDC for passwordless authentication to AWS. No plaintext secrets are stored in code or CI/CD logs.

    Environment Parity: Easily manage configuration differences between development, staging, and production using GitHub Environments.

    Idempotent & Repeatable: Ensures consistent deployments every time.

    Cloud Native: Utilizes modern Kubernetes patterns like the Secrets Store CSI Driver and Istio for traffic management.

2. Solution Architecture

The solution is composed of several key components that work in concert, orchestrated by a GitHub Actions workflow.

Components:

    GitHub Actions Workflow (.github/workflows/deploy.yml): The primary entry point for the entire workflow. It sets up the environment and orchestrates the execution.

    Deployment Script (deploy.sh): A shell script containing the core logic for running the Terraform and Helm stages. It is called by the GitHub Actions workflow.

    Terraform: Manages all AWS resources, including the RDS database instance and the secret in AWS Secrets Manager.

    AWS RDS & Secrets Manager: The managed database and secret store.

    Helm: Deploys the application onto the Kubernetes cluster.

    Kubernetes (EKS), Istio, and Secrets Store CSI Driver: The runtime environment for the application.

Deployment Flow Diagram:

+--------------------------+      +----------------------+      +----------------------+
| GitHub Actions Runner    |----->|      Terraform       |----->|       AWS Cloud      |
| (Executes deploy.sh)     |      | (terraform apply)    |      |                      |
+--------------------------+      +----------------------+      | 1. Create/Update RDS |
       |                                                        | 2. Create/Update     |
       |                                                        |    Secrets Manager   |
       |                                                        +-----------+----------+
       |                                                             |
       |                               (DB Host, Secret ARN)         |
       |                               <-----------------------------+
       |
       |
       v
+-------------------+      +----------------------+      +----------------------+
|       Helm        |----->|  Kubernetes Cluster  |      |   Secrets Store CSI  |
| (helm upgrade)    |      | (EKS with Istio)     |----->|        Driver        |
+-------------------+      +----------------------+      +----------+-----------+
                               |      ^                            |
                               |      | (Creates K8s Secret)       |
                               v      +----------------------------+
                      +------------------+
                      | Application Pod  |
                      | - Consumes Secret|
                      | - Connects to DB |
                      +------------------+

3. Prerequisites

Before running the deployment, ensure the following infrastructure and tools are in place.

Infrastructure:

    AWS Account & Existing Infrastructure: As outlined in Section 1.0 (VPC, Subnets, Security Groups, S3 Backend).

    Kubernetes Cluster (EKS): As outlined in Section 1.0 (Istio, CSI Driver installed).

    IAM OIDC Provider for GitHub Actions: An IAM OIDC identity provider must be configured in your AWS account to trust token.actions.githubusercontent.com.

    IAM Role for GitHub Actions: For each environment, an IAM role (e.g., github-actions-deploy-role-dev) must exist. This role needs:

        Permissions to manage RDS and Secrets Manager.

        A trust policy that allows the GitHub OIDC provider to assume it.

GitHub Setup:

    Repository Secrets: A secret named KUBE_CONFIG_DATA must be created in the repository (Settings > Secrets and variables > Actions). Its value should be the Base64-encoded content of the kubeconfig file for your cluster.

    GitHub Environments (Recommended): For enhanced security, configure an environment in GitHub for dev, staging, and prod. You can add protection rules and link environment-specific secrets if needed.

4. Configuration Guide

Configuration is managed in Terraform, Helm, and the GitHub Actions workflow file.
4.1. Terraform & Helm Configuration

(No changes from the previous version. See Section 1.0 for details on configuring .tfvars and values-*.yaml files).
4.2. GitHub Actions Workflow Configuration

The workflow is defined in .github/workflows/deploy.yml.

    role-to-assume: You must update the ARN in this line to point to the IAM role you created in your AWS account. Replace YOUR_AWS_ACCOUNT_ID with your account ID.

    role-to-assume: arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/github-actions-deploy-role-${{ github.event.inputs.environment }}

    aws-region: Set this to your target AWS region.

5. Deployment Workflow

The deployment is executed directly from the GitHub Actions UI.

Usage:

    Navigate to the Actions tab in your GitHub repository.

    In the left sidebar, select the Deploy Application and Database workflow.

    Click the Run workflow dropdown button.

    Choose the Target environment (dev, staging, or prod) from the dropdown menu.

    Click the green Run workflow button.

Stages of Execution:
The GitHub Actions runner will execute the steps defined in deploy.yml:

    Setup: The runner checks out the code and sets up all required CLI tools (Terraform, Helm, kubectl).

    Authentication: It securely authenticates with AWS using OIDC, assuming the appropriate IAM role for the target environment. It also configures kubectl using the KUBE_CONFIG_DATA secret.

    Execution: It calls the ./deploy.sh script, passing the chosen environment as an argument. The script then proceeds with the Terraform and Helm stages as described previously.

6. Security Considerations

This implementation enhances the security posture of the previous solution.

    Passwordless Authentication: The primary security benefit is the use of OIDC for authenticating with AWS. This removes the need for storing long-lived AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY as GitHub secrets. Credentials are temporary and automatically managed.

    Centralized Audit Trail: All deployments are now initiated and logged within GitHub Actions, providing a clear, auditable history of who deployed what, to which environment, and when.

    Secret Management, IRSA, Network Policy, State File Security: All other security considerations from the previous version remain in effect and are fully integrated into this workflow.
