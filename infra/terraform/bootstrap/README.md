# Bootstrap Terraform

This Terraform project should run before the [environment terraform](../omop/README.md).

![bootstrap environment](/infra/media/bootstrap_deplyment.png)

* TODO: Revisit links

This project will look to ease running your environment terraform and running OHDSI in Azure, including covering the following for each environment:

* Setup Azure Key Vault
* Setup Azure Storage Container for Backend TF statefile
* Setup Azure Virtual Machine Scale Set (for use later with your Azure DevOps VMSS Agent Pool)
  * This will use a custom image through cloud-init (and configured through the [ado builder config](./adobuilder.conf))
* Setup Azure Linux VM Jumpbox w/VNET
* Setup Azure DevOps Environment
* Setup Azure DevOps Variable Groups:
    * One for environment setup (e.g. your `bootstrap-vg`) linked to Azure Key Vault to run with your Environment Pipeline
    * One for application pipeline usage per environment (e.g. your `env-rg`)
* Setup Azure DevOps Service Connection to connect to Azure
* Setup and Import Azure DevOps Pipelines

## Setup Notes

* TODO: Local setup notes for working with TF Azure DevOps provider