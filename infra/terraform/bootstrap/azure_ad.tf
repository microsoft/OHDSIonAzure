#############################
# Azure AD Group for Azure SQL Admins
# This will hold the current admin user, the SP used for the Service Connection, and the Azure VMSS
# In the corresponding omop environment (/terraform/omop/output.tf), you should also have your administrator
# complete adding the Azure App Service to this group through Azure CLI
#############################

resource "azuread_group" "dbadminsaadgroup" {
  display_name  = "${var.prefix}-${var.environment}-omop-sql-server-admins"
  mail_nickname = "${var.prefix}-${var.environment}-omop-sql-server-admins"
  owners = toset([
    data.azuread_client_config.current.object_id,
  ])
  security_enabled = true

  # uncomment this if you have AAD premium enabled in your Azure subscription
  # https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept
  # assignable_to_role = true

  members = toset([
    data.azuread_client_config.current.object_id,
    azuread_service_principal.spomop.id,
    azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id
  ])
}

# This AAD Group is for Directory Readers.  You can add in the Azure SQL Server Managed Identity as a separate step.
# https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group
resource "azuread_group" "directoryreadersaadgroup" {
  display_name  = "${var.prefix}-${var.environment}-omop-sql-server-directory-readers"
  mail_nickname = "${var.prefix}-${var.environment}-omop-sql-server-directory-readers"
  owners = toset([
    data.azuread_client_config.current.object_id,
  ])
  security_enabled = true

  # You need AAD premium enabled in your Azure subscription to assign a role to the group
  # https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept
  assignable_to_role = true

  members = toset([
    data.azuread_client_config.current.object_id,
  ])
}

#############################
# Uncomment the following section if you have AAD premium enabled in your Azure subscription
# The following section will allow you to assign Directory Reader to your Azure AD group
# https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept
# Look to add in Directory Reader to your Azure AD Group: https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial#assign-directory-readers-permission-to-the-sql-logical-server-identity
#############################

resource "azuread_directory_role" "directoryreaders" {
  display_name = "Directory Readers"
}

resource "azuread_directory_role_member" "directoryreadersmember" {
  role_object_id   = azuread_directory_role.directoryreaders.object_id
  member_object_id = azuread_group.directoryreadersaadgroup.object_id
}