output "app_service_default_hostname_atlas" {
  value = "https://${azurerm_app_service.omop_broadsea.default_site_hostname}/atlas"
}

output "azure_cli_for_sql_server_admin" {
  value = <<EOF

    Your Administrator should run the following commands as part of your Azure SQL Server setup:

    # add Azure App Service to the Azure SQL DB group
    az ad group member add -g ${var.ad_admin_object_id} --member-id ${azurerm_app_service.omop_broadsea.identity[0].principal_id}
  EOF
}

# output "attach_azure_sql_server_admin" {
#   # az sql server ad-admin create -g $sqlRgName -s $sqlServerName -i $sqlAdminGroupObjectId -u $sqlAdminsAADGroupName
#   value = "az sql server ad-admin create -g ${azurerm_resource_group.omop_rg.name} -s ${var.prefix}-${var.environment}-omop-sql-server -i ${azuread_group.dbadminsaadgroup.object_id} -u ${azuread_group.dbadminsaadgroup.display_name}"
# }