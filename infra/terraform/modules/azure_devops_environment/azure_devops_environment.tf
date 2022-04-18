# Using a second version of the provider (workaround until Azure DevOps Provider https://github.com/microsoft/terraform-provider-azuredevops/issues/541 is ready)
# PLUGIN_PATH=/usr/share/terraform/plugins/registry.terraform.io/microsoft/azuredevops2/0.2.0/linux_amd64
# mkdir -p $PLUGIN_PATH
# curl -sLo_ 'https://github.com/microsoft/terraform-provider-azuredevops/releases/download/v0.2.0/terraform-provider-azuredevops_0.2.0_linux_amd64.zip'
# unzip -p _ 'terraform-provider-azuredevops*' > ${PLUGIN_PATH}/terraform-provider-azuredevops2_v0.2.0
# rm _
# chmod 755 ${PLUGIN_PATH}/terraform-provider-azuredevops2_v0.2.0

terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    azuredevops2 = {
      source = "microsoft/azuredevops2"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuredevops2" {
  org_service_url       = var.ado_org_service_url
  personal_access_token = var.ado_pat
}

# Azure DevOps Environment
resource "azuredevops_environment" "adoenvironment" {
  provider   = azuredevops2
  project_id = var.ado_project_id
  name       = var.environment_name
}