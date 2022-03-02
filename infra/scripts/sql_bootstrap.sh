# AAD for Azure SQL variables
sqlAdminsAADGroupName=My-Sharing-DB-Admins
sqlAdminsAADMailNickname=My-Sharing-DB-Admins
sqlRgName=sharing-dev-omop-rg
sqlServerName=sharing-dev-omop-sql-server
spAppId='sp-app-id' # from the ado_bootstrap.sh script
spObjectId=$(az ad sp show --id $spAppId | jq -r ".objectId")
appServiceName=sharing-dev-omop-broadsea
appServiceObjectId=$(az webapp identity show -g $sqlRgName -n $appServiceName | jq -r ".principalId")
adoBuildAgentPoolName=vmssagentspool
adoBuildAgentRgName=ado-omop-bootstrap-rg
vmssIdentityJson=$(az vmss identity assign --identities '[system]' -n $adoBuildAgentPoolName -g $adoBuildAgentRgName)
vmssIdentityObjectId=$(echo $vmssIdentityJson | jq -r ".systemAssignedIdentity") # add this identity to DB admin group

# You can set up your Azure SQL Admin
# https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-configure?tabs=azure-powershell#powershell-for-sql-database-and-azure-synapse
sqlAdminGroupJson=$(az ad group create --display-name $sqlAdminsAADGroupName --mail-nickname $sqlAdminsAADMailNickname)
sqlAdminGroupObjectId=$(echo $sqlAdminGroupJson | jq -r ".objectId")

# Add a user to the group
userObjectId=$(az ad signed-in-user show | jq -r ".objectId")
az ad group member add -g $sqlAdminGroupObjectId --member-id $userObjectId

# TODO: can this move over to TF instead (Currently have a cycle between Azure SQL / Azure App Service)
# add SP to group
az ad group member add -g $sqlAdminGroupObjectId --member-id $spObjectId

# add App Service to group
az ad group member add -g $sqlAdminGroupObjectId --member-id $appServiceObjectId

# add ADO Build Agent VMSS to group
az ad group member add -g $sqlAdminGroupObjectId --member-id $vmssIdentityObjectId

# add the group to Azure SQL as an AD Admin
az sql server ad-admin create -g $sqlRgName -s $sqlServerName -i $sqlAdminGroupObjectId -u $sqlAdminsAADGroupName