terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    # Using 0.1.8 provider for variable groups until fix is pushed for
    # https://github.com/microsoft/terraform-provider-azuredevops/issues/541
    azuredevops = {
      source = "microsoft/azuredevops"
      #   version = ">=0.2.0"
      version = "~>0.1.8"
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

data "azuread_client_config" "current" {}
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "adobootstrap" {
  name     = "${var.prefix}-${var.environment}-ado-bootstrap-omop-rg"
  location = var.location
  tags     = var.tags
}

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  number  = false
}

#############################
# Azure Key Vault
# Used for Key Vault Linked Variable Group for Bootstrap
#############################

resource "azurerm_key_vault" "keyvault" {
  name                        = "${var.prefix}-${var.environment}-omop-kv"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.adobootstrap.name
  enabled_for_disk_encryption = true
  tenant_id                   = sensitive(data.azurerm_client_config.current.tenant_id)
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy = [
    {
      tenant_id      = sensitive(data.azurerm_client_config.current.tenant_id)
      object_id      = sensitive(data.azurerm_client_config.current.object_id)
      application_id = null

      secret_permissions = [
        "Backup",
        "Get",
        "List",
        "Purge",
        "Recover",
        "Restore",
        "Set",
        "Delete",
      ]
      certificate_permissions = [
        "Get",
        "List",
        "Update",
        "Create",
        "Import",
        "Delete",
        "Recover",
        "Backup",
        "Restore",
      ]
      key_permissions = [
        "Get",
        "List",
        "Update",
        "Restore",
        "Backup",
        "Recover",
        "Delete",
        "Import",
        "Create",
      ]
      storage_permissions = [
      ]
    },
    ## Grant SP permissions
    {
      tenant_id      = sensitive(data.azurerm_client_config.current.tenant_id)
      object_id      = sensitive(azuread_service_principal.spomop.object_id)
      application_id = null
      secret_permissions = [
        "Get",
        "List",
      ]
      certificate_permissions = [
      ]
      key_permissions = [
      ]
      storage_permissions = [
      ]
    }
  ]
}

## Create secrets
# Note that key vault secrets must match the name (and key vault secrets don't allow underscores)
resource "azurerm_key_vault_secret" "omopPassword" {
  key_vault_id = azurerm_key_vault.keyvault.id
  name         = "omopPassword"
  value        = var.omop_password
}

# this is assumed to be the bootstrap administrator id
resource "azurerm_key_vault_secret" "bootstrapAdminObjectId" {
  key_vault_id = azurerm_key_vault.keyvault.id
  name         = "bootstrapAdminObjectId"
  value        = data.azuread_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "spServiceConnectionObjectId" {
  key_vault_id = azurerm_key_vault.keyvault.id
  name         = "spServiceConnectionObjectId"
  value        = azuread_service_principal.spomop.id
}

resource "azurerm_key_vault_secret" "vmssManagedIdentityObjectId" {
  key_vault_id = azurerm_key_vault.keyvault.id
  name         = "vmssManagedIdentityObjectId"
  value        = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id
}

resource "azurerm_key_vault_secret" "storageAccountKey" {
  key_vault_id = azurerm_key_vault.keyvault.id
  name         = "storageAccountKey"
  value        = azurerm_storage_account.tfstatesa.primary_access_key
}

#############################
# Azure Storage
# Used for bootstrap TF State
#############################

resource "azurerm_storage_account" "tfstatesa" {
  name                     = "${var.prefix}${var.environment}tfstatesa"
  resource_group_name      = azurerm_resource_group.adobootstrap.name
  location                 = azurerm_resource_group.adobootstrap.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = var.tags
}

resource "azurerm_storage_container" "tfstatecontainer" {
  name                  = "${var.prefix}-${var.environment}-statefile-container"
  storage_account_name  = azurerm_storage_account.tfstatesa.name
  container_access_type = "private"
}

#############################
# Azure Virtual Network
#############################

resource "azurerm_virtual_network" "vmss" {
  name                = "${var.prefix}-${var.environment}-vmss-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.adobootstrap.name
  tags                = var.tags
}

resource "azurerm_subnet" "vmss" {
  name                 = "${var.prefix}-${var.environment}-vmss-subnet"
  resource_group_name  = azurerm_resource_group.adobootstrap.name
  virtual_network_name = azurerm_virtual_network.vmss.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vmss" {
  name                = "${var.prefix}-${var.environment}-vmss-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.adobootstrap.name
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = random_string.fqdn.result
  tags                = var.tags
}

#############################
# Azure Virtual Machine Scale Set (VMSS)
# This will be used for the Azure DevOps agent pool
# Note that linking the VMSS to Azure DevOps as an agent pool in TF is still a TODO
# https://github.com/microsoft/terraform-provider-azuredevops/issues/204
# And revisit setting up elastic pools https://github.com/microsoft/terraform-provider-azuredevops/issues/368
#############################

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.prefix}-${var.environment}-ado-build-linux-vmss-agent"
  location            = var.location
  resource_group_name = azurerm_resource_group.adobootstrap.name
  upgrade_mode        = "Manual"
  admin_username      = var.admin_user
  admin_password      = var.admin_password

  custom_data                     = base64encode(file("adobuilder.conf"))
  disable_password_authentication = false
  sku                             = var.azure_vmss_sku
  instances                       = var.azure_vmss_instances
  overprovision                   = false
  single_placement_group          = false
  platform_fault_domain_count     = 1

  source_image_reference {
    publisher = var.azure_vmss_source_image_publisher
    offer     = var.azure_vmss_source_image_offer
    sku       = var.azure_vmss_source_image_sku
    version   = var.azure_vmss_source_image_version
  }

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name      = "IPConfiguration"
      subnet_id = azurerm_subnet.vmss.id
      primary   = true
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # ignore changes to tags for Azure DevOps
      tags["__AzureDevOpsElasticPool"],
      tags["__AzureDevOpsElasticPoolTimeStamp"],
    ]
  }
}

#############################
# Azure Windows Virtual Machine Scale Set (VMSS)
# This will be used for the Azure DevOps agent pool
# Note that linking the Windows VMSS to Azure DevOps as an agent pool in TF is still a TODO
# https://github.com/microsoft/terraform-provider-azuredevops/issues/204
# And revisit setting up elastic pools https://github.com/microsoft/terraform-provider-azuredevops/issues/368
#############################

resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  name                 = "${var.prefix}-${var.environment}-ado-build-windows-vmss-agent"
  computer_name_prefix = "ado-build" # 9 character limit for prefix
  location             = var.location
  resource_group_name  = azurerm_resource_group.adobootstrap.name
  upgrade_mode         = "Manual"
  admin_username       = var.admin_user
  admin_password       = var.admin_password

  # Copy in script data
  custom_data = base64encode(file("scripts/build-agent-dependencies.ps1"))

  sku                         = var.azure_windows_vmss_sku
  instances                   = var.azure_windows_vmss_instances
  overprovision               = false
  single_placement_group      = false
  platform_fault_domain_count = 1

  source_image_reference {
    publisher = var.azure_windows_vmss_source_image_publisher
    offer     = var.azure_windows_vmss_source_image_offer
    sku       = var.azure_windows_vmss_source_image_sku
    version   = var.azure_windows_vmss_source_image_version
  }

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name      = "IPConfiguration"
      subnet_id = azurerm_subnet.vmss.id
      primary   = true
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # ignore changes to tags for Azure DevOps
      tags["__AzureDevOpsElasticPool"],
      tags["__AzureDevOpsElasticPoolTimeStamp"],
    ]
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "script_build_agent_dependencies" {
  name                         = "${var.prefix}-${var.environment}-build-agent-dependencies"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.vmss.id
  publisher                    = "Microsoft.Compute"
  type                         = "CustomScriptExtension"
  type_handler_version         = "1.10"

  # run custom script
  settings = jsonencode(
    {
      "commandToExecute" : "powershell.exe -ExecutionPolicy Unrestricted -Command \"Copy-Item C:/AzureData/CustomData.bin ./build-agent-dependencies.ps1 -Force; ./build-agent-dependencies.ps1 *> C:/WindowsAzure/Logs/build-agent-dependencies.log\""
  })
}

#############################
# Jumpbox Settings
#############################

resource "azurerm_public_ip" "jumpbox" {
  name                = "${var.prefix}-${var.environment}-jumpbox-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.adobootstrap.name
  allocation_method   = "Static"
  domain_name_label   = "${random_string.fqdn.result}-ssh"
  tags                = var.tags
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "${var.prefix}-${var.environment}-jumpbox-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.adobootstrap.name

  ip_configuration {
    name                          = "${var.prefix}-${var.environment}-IPConfiguration"
    subnet_id                     = azurerm_subnet.vmss.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }

  tags = var.tags
}

#############################
# Azure VM
# This is a jumpbox for testing VMSS instances
# You can either use an Azure Linux VM or an Azure Windows VM as your jumpbox
#############################

## Uncomment if you prefer to use an Azure Linux VM for your jumpbox
# resource "azurerm_virtual_machine" "jumpbox" {
#   name                  = "${var.prefix}-${var.environment}-jumpbox"
#   location              = var.location
#   resource_group_name   = azurerm_resource_group.adobootstrap.name
#   network_interface_ids = [azurerm_network_interface.jumpbox.id]
#   vm_size               = "Standard_DS1_v2"

#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }

#   storage_os_disk {
#     name              = "${var.prefix}-${var.environment}-jumpbox-osdisk"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }

#   os_profile {
#     computer_name  = "${var.prefix}-${var.environment}-jumpbox"
#     admin_username = var.admin_user_jumpbox
#     admin_password = var.admin_password_jumpbox
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   tags = var.tags
# }

## Uncomment if you prefer to use an Azure Windows VM for your jumpbox
resource "azurerm_windows_virtual_machine" "jumpbox-windows" {
  name                = "${var.prefix}${var.environment}jump" # 15 character limit
  resource_group_name = azurerm_resource_group.adobootstrap.name
  location            = var.location
  size                = "Standard_DS1_v2"
  admin_username      = var.admin_user_jumpbox
  admin_password      = var.admin_password_jumpbox
  network_interface_ids = [
    azurerm_network_interface.jumpbox.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Windows Server 2019 includes Open SSH
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
