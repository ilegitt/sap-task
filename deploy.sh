#!/bin/bash
#
# This script automates the deployment of the application and its database.
# It uses AWS Secrets Manager for secure credential handling.
#
# Usage: ./deploy.sh <environment>
# Example: ./deploy.sh staging

# --- Configuration and Setup ---
set -e # Exit immediately if a command exits with a non-zero status.
set -o pipefail # Fail a pipeline if any command fails.

# Validate input: Ensure an environment is specified.
if [ -z "$1" ]; then
  echo " Error: No environment specified."
  echo "Usage: $0 <dev|staging|prod>"
  exit 1
fi

ENVIRONMENT="$1"
TERRAFORM_DIR="terraform"
HELM_CHART_DIR="helm/my-application"
HELM_RELEASE_NAME="my-app-${ENVIRONMENT}"
K8S_NAMESPACE="app-${ENVIRONMENT}" # Use a dedicated namespace for each environment


echo " Starting Deployment for Environment: [${ENVIRONMENT}]"

# --- Stage 1: Terraform Infrastructure ---
echo " [1/2] Provisioning database and secret with Terraform..."

cd "${TERRAFORM_DIR}"

# Initialize Terraform. The -reconfigure flag is useful in CI/CD if the backend config changes.
echo " Initializing Terraform..."
terraform init -reconfigure

# Select the Terraform workspace corresponding to the environment.
# This ensures state files for different environments are kept separate.
if ! terraform workspace select "${ENVIRONMENT}" 2>/dev/null; then
  echo " Workspace '${ENVIRONMENT}' not found. Creating new workspace."
  terraform workspace new "${ENVIRONMENT}"
fi

# Apply Terraform changes.
echo " Applying Terraform plan for [${ENVIRONMENT}]..."
terraform apply -var-file="envs/${ENVIRONMENT}.tfvars" -auto-approve

# Extract database details from Terraform outputs.
echo " Fetching database connection details from Terraform outputs..."
DB_HOST=$(terraform output -raw db_endpoint)
DB_USER=$(terraform output -raw db_username)
DB_SECRET_ARN=$(terraform output -raw db_secret_arn) # Fetching the secret ARN instead of the password

# Check if Terraform outputs were retrieved successfully.
if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_SECRET_ARN" ]; then
    echo " Error: Failed to retrieve database details from Terraform outputs."
    exit 1
fi

echo " Terraform stage completed successfully."
cd ..

# --- Stage 2: Helm Application Deployment ---
echo " [2/2] Deploying application with Helm..."

# The helm command now passes the secret ARN instead of the password.
helm upgrade --install "${HELM_RELEASE_NAME}" "${HELM_CHART_DIR}" \
  --namespace "${K8S_NAMESPACE}" \
  --create-namespace \
  -f "${HELM_CHART_DIR}/values.yaml" \
  -f "${HELM_CHART_DIR}/values-${ENVIRONMENT}.yaml" \
  --set-string database.host="${DB_HOST}" \
  --set-string database.user="${DB_USER}" \
  --set-string database.secretArn="${DB_SECRET_ARN}" \
  --wait # Wait for the release to be in a ready state.

echo " Helm deployment completed successfully."


