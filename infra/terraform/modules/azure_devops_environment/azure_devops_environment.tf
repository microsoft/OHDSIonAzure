terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuredevops" {
  org_service_url       = var.ado_org_service_url
  personal_access_token = var.ado_pat
}

# Azure DevOps Environment
resource "azuredevops_environment" "adoenvironment" {
  provider   = azuredevops
  project_id = var.ado_project_id
  name       = var.environment_name
}