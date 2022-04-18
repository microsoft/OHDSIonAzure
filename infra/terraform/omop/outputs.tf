output "app_service_default_hostname_atlas" {
  value = "https://${azurerm_app_service.omop_broadsea.default_site_hostname}/atlas"
}

output "azure_cli_for_sql_server_admin" {
  value = <<EOF

    Your Administrator should run the following Azure CLI commands as part of your Azure SQL Server setup:

    # add Azure App Service to the Azure SQL DB group
    az ad group member add -g ${var.aad_admin_object_id} --member-id ${azurerm_app_service.omop_broadsea.identity[0].principal_id}

    # add Azure SQL Managed Identity to Azure AD Group for Directory Readers
    # https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group
    az ad group member add -g ${var.aad_directory_readers_object_id} --member-id ${azurerm_mssql_server.omop_sql_server.identity[0].principal_id}

  EOF
}

output "azure_sql_managed_identity_query" {
  value = <<EOF
    If your administrator has not assigned Directory Readers (https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group)
    for your Azure SQL Managed Identity, you will need your Administrator 
    to run the following SQL queries as part of your Azure SQL Server setup:
    
    -- Add in your Azure App Service for Broadsea
    CREATE USER [${var.prefix}-${var.environment}-omop-broadsea] FROM EXTERNAL PROVIDER
    ALTER ROLE db_datareader ADD MEMBER [${var.prefix}-${var.environment}-omop-broadsea]
    ALTER ROLE db_datawriter ADD MEMBER [${var.prefix}-${var.environment}-omop-broadsea]
    ALTER ROLE db_owner ADD MEMBER [${var.prefix}-${var.environment}-omop-broadsea]

    -- Add in the Azure VMSS for your Azure DevOps Agent VMSS Pool
    CREATE USER [${var.ado_agent_pool_vmss_name}] FROM EXTERNAL PROVIDER;
    ALTER ROLE db_datareader ADD MEMBER [${var.ado_agent_pool_vmss_name}]
    ALTER ROLE db_datawriter ADD MEMBER [${var.ado_agent_pool_vmss_name}]
    ALTER ROLE db_owner ADD MEMBER [${var.ado_agent_pool_vmss_name}]

    Note, this query is included as part of the /sql/scripts/Post_TF_Deploy.sql and can be run if you have
    enabled Directory Reader for your Azure SQL Managed Identity.
    This Azure SQL Managed Identity can be added to your Azure AD Group with Directory Reader assigned.
    See the following for more details: https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial#assign-directory-readers-permission-to-the-sql-logical-server-identity

  EOF
}