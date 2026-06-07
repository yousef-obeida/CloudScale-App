terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  # Remote backend configuration for GitHub Actions
  # We will configure the exact storage account details later in the CI/CD phase
  backend "azurerm" {
    # resource_group_name  = "terraform-state-rg"
    # storage_account_name = "tfstatecloudscale"
    # container_name       = "tfstate"
    # key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}