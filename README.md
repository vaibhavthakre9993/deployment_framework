# Self-Service Deployment Platform Template

This repository serves as a template to easily deploy any application to Azure using GitHub Actions, Docker, and Terraform. It automatically provisions Azure Container Apps, a PostgreSQL database, and a Virtual Network.

## How to Use This Template

1. Click on the **Use this template** button at the top of the repository to create your own repository.
2. Clone your new repository to your local machine.
3. Update the `config.yml` at the root of the project to match your application's details:
   - `app_name`: The name of your application.
   - `port`: The port your application runs on.
   - `subdomain`: Your desired subdomain (e.g., `myapp.poc.xoriant.com`).
   - `language`: The language/runtime of your app (e.g., `node`).
4. Replace the source code in this repository with your own application's code. Make sure your application can run with standard commands (like `npm start` for Node.js) or update the `Dockerfile` accordingly.

## GitHub Secrets

Before deploying, you must configure the following Secrets in your GitHub repository (`Settings` -> `Secrets and variables` -> `Actions`):

- `DOCKER_USERNAME`: Your Docker Hub username.
- `DOCKER_PASSWORD`: Your Docker Hub password or Personal Access Token.
- `AZURE_CREDENTIALS`: The JSON credentials for an Azure Service Principal with Contributor access to your subscription.
- `AZURE_RESOURCE_GROUP`: The name of the Azure Resource Group where you want to deploy your infrastructure. (Ensure the Service Principal has permissions to manage this resource group).

## How to Run Terraform Locally (Optional)

The GitHub Actions workflow runs Terraform automatically on every push to the `main` branch. However, if you want to test or apply the Terraform code locally:

1. Install [Terraform](https://developer.hashicorp.com/terraform/downloads) and the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
2. Log in to Azure:
   ```bash
   az login
   ```
3. Navigate to the `terraform/` directory:
   ```bash
   cd terraform
   ```
4. Copy the example variables file and adjust the values:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
5. Initialize Terraform:
   ```bash
   terraform init
   ```
6. Plan and apply the infrastructure:
   ```bash
   terraform plan
   terraform apply
   ```

## How to Push Code and Deploy

Once you have configured `config.yml` and added the required GitHub Secrets:

1. Add your changes:
   ```bash
   git add .
   ```
2. Commit your code:
   ```bash
   git commit -m "Initial commit for deployment"
   ```
3. Push to the `main` branch:
   ```bash
   git push origin main
   ```

The GitHub Action (`.github/workflows/deploy.yml`) will automatically trigger. It will:
- Parse your `config.yml`.
- Build a generic Docker container for your app and push it to Docker Hub.
- Run Terraform to provision the required Azure infrastructure (VNet, Subnets, Container Apps, and PostgreSQL DB).
- Deploy the Docker container to the Azure Container App.
