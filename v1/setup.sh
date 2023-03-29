#!/bin/bash

########################################
###### Backend Bootstrap Settings ######
########################################

AZURE_SERVICE_PRINCIPAL_NAME=${AZURE_SERVICE_PRINCIPAL_NAME:-prefix-environment-OHDSI-on-Azure-SP}
BOOTSTRAP_TF_BACKEND_LOCATION=${BOOTSTRAP_TF_BACKEND_LOCATION:-westus3}
BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME=${BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME:-bootstraptfstatesa}
BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME=${BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME:-bootstrap-tf-state-rg}
BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_CONTAINER_NAME=${BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_CONTAINER_NAME:-prefix-environment-tfstate}
BOOTSTRAP_TF_BACKEND_FILENAME=${BOOTSTRAP_TF_BACKEND_FILENAME:-terraform.tfstate}

####################################
###### Setup Bootstrap Values ######
####################################

# Additional Configuration for OHDSI on Azure (bootstrap / omop), should be passed in
ADO_PAT=${ADO_PAT:-your Azure DevOps PAT}
OMOP_PASSWORD=${OMOP_PASSWORD:-replaceMyP4SSW0RD.}
ADMIN_USER_JUMPBOX=${ADMIN_USER_JUMPBOX:-azureuser}
ADMIN_PASSWORD_JUMPBOX=${ADMIN_PASSWORD_JUMPBOX:-replaceYourJumpboxP4SSW0RD.}
ADMIN_USER=${ADMIN_USER:-azureuser}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-replaceYourVMSSP4SSW0RD.}
PREFIX=${PREFIX:-ohdsi}
ENVIRONMENT=${ENVIRONMENT:-dev00}
ADO_ORGANIZATION_NAME=${ADO_ORGANIZATION_NAME:-my-ado-org-name}

#############################################
## Optional - Pass in Azure SP Credentials ##
#############################################

AZURE_CLIENT_ID=${AZURE_CLIENT_ID:-my azure client id}
AZURE_CLIENT_OBJECT_ID=${AZURE_CLIENT_OBJECT_ID:-my azure client object id}
AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET:-my azure client secret}
AZURE_TENANT_ID=${AZURE_TENANT_ID:-my azure tenant id}
AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID:-my azure subscription id}

############################
###### Default Values ######
############################

# Include debugging output, set to 1 to enable
INCLUDE_DEBUGGING_OUTPUT=${INCLUDE_DEBUGGING_OUTPUT:-0}

# Include Key Vault Porter Secrets, set to 1 to enable
INCLUDE_KEY_VAULT_PORTER_SECRETS=${INCLUDE_KEY_VAULT_PORTER_SECRETS:-1}

# Create new Azure Service Principal
CREATE_NEW_AZURE_SERVICE_PRINCIPAL=${CREATE_NEW_AZURE_SERVICE_PRINCIPAL:-1}

# Copy vocabulary from demo vocabulary Azure Storage Account container
SOURCE_VOCABULARIES_STORAGE_ACCOUNT_NAME=${SOURCE_VOCABULARIES_STORAGE_ACCOUNT_NAME:-demovocabohdsionazure}
SOURCE_VOCABULARIES_STORAGE_ACCOUNT_CONTAINER=${SOURCE_VOCABULARIES_STORAGE_ACCOUNT_CONTAINER:-vocabularies}

# Vocabulary Settings
VOCABULARIES_CONTAINER_NAME=${VOCABULARIES_CONTAINER_NAME:-vocabularies}
VOCABULARIES_CONTAINER_PATH=${VOCABULARIES_CONTAINER_PATH:-vocabularies/19-AUG-2021}
VOCABULARIES_SEARCH_PATTERN=${VOCABULARIES_SEARCH_PATTERN:-19-AUG-2021/*.csv}

# Retry Settings with default values
CHECK_RETRY_COUNT=${CHECK_RETRY_COUNT:-50}
CHECK_SECONDS=${CHECK_SECONDS:-60}

# Default Values which can also be adjusted, should be configured depending on Terraform updates
BROADSEA_BUILD_PIPELINE_NAME=${BROADSEA_BUILD_PIPELINE_NAME:-Broadsea Build Pipeline}
BROADSEA_RELEASE_PIPELINE_NAME=${BROADSEA_RELEASE_PIPELINE_NAME:-Broadsea Release Pipeline}
ENVIRONMENT_DESTROY_PIPELINE_NAME=${ENVIRONMENT_DESTROY_PIPELINE_NAME:-TF Destroy OMOP Environment Pipeline}
ENVIRONMENT_PIPELINE_NAME=${ENVIRONMENT_PIPELINE_NAME:-TF Apply OMOP Environment Pipeline}
LOG_SEARCH_PATTERN=${LOG_SEARCH_PATTERN:-Your Administrator should run the following Azure CLI commands as part of your Azure SQL Server setup:}
PIPELINE_BRANCH_NAME=${PIPELINE_BRANCH_NAME:-main}
VOCABULARY_BUILD_PIPELINE_NAME=${VOCABULARY_BUILD_PIPELINE_NAME:-Vocabulary Build Pipeline}
VOCABULARY_RELEASE_PIPELINE_NAME=${VOCABULARY_RELEASE_PIPELINE_NAME:-Vocabulary Release Pipeline}

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare "$param"="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

########################################
###### Setup Backend for Boostrap ######
########################################

# This assumes you're running as your administrator account

# Create resource group
az group create --name "$BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME" --location "$BOOTSTRAP_TF_BACKEND_LOCATION"

# Create storage account
STORAGE_ACCOUNT_RESULT=$(az storage account list -g "$BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME")
STORAGE_ACCOUNT_EXISTS=$(echo "$STORAGE_ACCOUNT_RESULT" | jq -r ".[] | select(.name==\"$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME\")")

if [ -n "$STORAGE_ACCOUNT_EXISTS" ]
then
    echo "Bootstrap Backend Storage Account already exists"
else
    echo "Bootstrap Backend Storage Account doesn't exist"
    az storage account create --resource-group "$BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME" --name "$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME" --sku Standard_LRS --encryption-services blob    
fi

echo "$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME"
# Create blob container
echo az storage container create --name "$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_CONTAINER_NAME" --account-name "$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME"
az storage container create --name "$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_CONTAINER_NAME" --account-name "$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME"

ACCOUNT_KEY=$(az storage account keys list --resource-group "$BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME" --account-name "$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME" --query '[0].value' -o tsv)

###########################################
###### Setup Azure Service Principal ######
###########################################

if [[ $CREATE_NEW_AZURE_SERVICE_PRINCIPAL == "1" ]];
then
    echo 'Creating new Azure SP'

    SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
    spJson=$(az ad sp create-for-rbac -n "$AZURE_SERVICE_PRINCIPAL_NAME" --role "Owner" --scopes "/subscriptions/$SUBSCRIPTION_ID")

    # echo "$spJson"
    # Get Service Principal Information
    spAppId=$(echo "$spJson" | jq -r ".appId")
    spPassword=$(echo "$spJson" | jq -r ".password")
    spTenantId=$(echo "$spJson" | jq -r ".tenant")

    # Get the object id.  Changed to '.id' for az cli version 2.37
    # https://docs.microsoft.com/en-us/cli/azure/microsoft-graph-migration
    spObjectId=$(az ad sp show --id "$spAppId" --query "id" -o tsv)

    if [ -z "$spObjectId" ];
    then
        echo "Try to query for objectId instead"
        spObjectId=$(az ad sp show --id "$spAppId" --query "objectId" -o tsv)
    fi
else
    echo 'Using existing Azure SP'

    spAppId=${AZURE_CLIENT_ID}
    spObjectId=${AZURE_CLIENT_OBJECT_ID}
    spPassword=${AZURE_CLIENT_SECRET}
    spTenantId=${AZURE_TENANT_ID}
    SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}
fi

# Setup current Azure Service principal with scope as the administrator user
# RoleAssignmentSchedule.ReadWrite.Directory,RoleAssignmentSchedule.ReadWrite.All,RoleManagement.ReadWrite.Directory
az ad app permission grant --id "$spObjectId" --api "00000003-0000-0000-c000-000000000000" \
    --scope "User.ReadWrite.All,Group.ReadWrite.All,Directory.Read.All,RoleManagement.ReadWrite.Directory"

# https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference
APPLICATION_ADMINISTRATOR_ROLE_ID='9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3'
GROUPS_ADMINISTRATOR_ROLE_ID='fdd7a751-b60b-444a-984c-02652fe8fa1c'
USER_ADMINISTRATOR_ROLE_ID='fe930be7-5e62-47db-91af-98c3a49a38b1'
PRIVILEGED_ROLE_ADMINISTRATOR_ROLE_ID='e8611ab8-c189-46e8-94e1-60213ab1f814'

# Assign a role
# https://docs.microsoft.com/en-us/azure/active-directory/roles/manage-roles-portal#microsoft-graph-pim-api
CHECK_ROLE_ASSIGNMENTS_URL="https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?"
# shellcheck disable=SC2016
CHECK_ROLE_ASSIGNMENTS_URL+='$filter = principalId eq'
CHECK_ROLE_ASSIGNMENTS_URL+=" '$spObjectId'"

CURRENT_ASSIGNMENTS_RESULT=$(az rest \
    --method GET \
    --url "$CHECK_ROLE_ASSIGNMENTS_URL")

# Assign Application Administrator Role to Service Principal
SP_HAS_ROLE=$(echo "$CURRENT_ASSIGNMENTS_RESULT" \
    | jq -r ".value[] | select(.roleDefinitionId==\"$APPLICATION_ADMINISTRATOR_ROLE_ID\" and .principalId==\"$spObjectId\")")

ROLE_ASSIGNMENTS_URL="https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments"

if [ -n "$SP_HAS_ROLE" ]
then
    echo "Service Principal $spObjectId is already assigned Application Administrator"
else
    echo "Assigning Service Principal $spObjectId Application Administrator"
    az rest \
    --method POST \
    --url "$ROLE_ASSIGNMENTS_URL" \
    --body "{ 
        \"@odata.type\": \"#microsoft.graph.unifiedRoleAssignment\",
        \"roleDefinitionId\": \"$APPLICATION_ADMINISTRATOR_ROLE_ID\",
        \"principalId\": \"$spObjectId\",
        \"directoryScopeId\": \"/\"
    }"
fi

# Assign Groups Administrator Role to Service Principal
SP_HAS_ROLE=$(echo "$CURRENT_ASSIGNMENTS_RESULT" \
    | jq -r ".value[] | select(.roleDefinitionId==\"$GROUPS_ADMINISTRATOR_ROLE_ID\" and .principalId==\"$spObjectId\")")

if [ -n "$SP_HAS_ROLE" ]
then
    echo "Service Principal $spObjectId is already assigned Groups Administrator"
else
    echo "Assigning Service Principal $spObjectId Groups Administrator"
    az rest \
    --method POST \
    --url "$ROLE_ASSIGNMENTS_URL" \
    --body "{ 
        \"@odata.type\": \"#microsoft.graph.unifiedRoleAssignment\",
        \"roleDefinitionId\": \"$GROUPS_ADMINISTRATOR_ROLE_ID\",
        \"principalId\": \"$spObjectId\",
        \"directoryScopeId\": \"/\"
    }"
fi

# Assign User Administrator Role to Service Principal
SP_HAS_ROLE=$(echo "$CURRENT_ASSIGNMENTS_RESULT" \
    | jq -r ".value[] | select(.roleDefinitionId==\"$USER_ADMINISTRATOR_ROLE_ID\" and .principalId==\"$spObjectId\")")

if [ -n "$SP_HAS_ROLE" ]
then
    echo "Service Principal $spObjectId is already assigned User Administrator"
else
    echo "Assigning Service Principal $spObjectId User Administrator"
    az rest \
    --method POST \
    --url "$ROLE_ASSIGNMENTS_URL" \
    --body "{ 
        \"@odata.type\": \"#microsoft.graph.unifiedRoleAssignment\",
        \"roleDefinitionId\": \"$USER_ADMINISTRATOR_ROLE_ID\",
        \"principalId\": \"$spObjectId\",
        \"directoryScopeId\": \"/\"
    }"
fi

# Assign Privileged Role Administrator to Service Principal
if [ -n "$SP_HAS_ROLE" ]
then
    echo "Service Principal $spObjectId is already assigned Privileged Role Administrator"
else
    echo "Assigning Service Principal $spObjectId Privileged Role Administrator"
    az rest \
    --method POST \
    --url "$ROLE_ASSIGNMENTS_URL" \
    --body "{ 
        \"@odata.type\": \"#microsoft.graph.unifiedRoleAssignment\",
        \"roleDefinitionId\": \"$PRIVILEGED_ROLE_ADMINISTRATOR_ROLE_ID\",
        \"principalId\": \"$spObjectId\",
        \"directoryScopeId\": \"/\"
    }"
fi

###################################
###### Setup Azure Key Vault ######
###################################

if [[ $INCLUDE_KEY_VAULT_PORTER_SECRETS == "1" ]];
then
    PORTER_BOOTSTRAP_AZURE_KEY_VAULT="$PREFIX-$ENVIRONMENT-kv"

    # check if the key vault already exists
    AZURE_KEY_VAULT_RESULT=$(az keyvault list -g "$BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME")
    CURRENT_AZURE_KEY_VAULT=$(echo "$AZURE_KEY_VAULT_RESULT" | jq -r ".[] | select(.name==\"$PORTER_BOOTSTRAP_AZURE_KEY_VAULT\")")

    if [ -z "$CURRENT_AZURE_KEY_VAULT" ]
    then
        echo "Azure Key vault $PORTER_BOOTSTRAP_AZURE_KEY_VAULT not found.  Creating Azure Key vault $PORTER_BOOTSTRAP_AZURE_KEY_VAULT"
        az keyvault create \
            -l "$BOOTSTRAP_TF_BACKEND_LOCATION" \
            -n "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
            -g "$BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME"
    else
        echo "Azure Key vault $PORTER_BOOTSTRAP_AZURE_KEY_VAULT already exists"
    fi

    # Setup Azure Key Vault Access
    az keyvault set-policy \
        -n "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        --secret-permissions get list \
        --object-id "$spObjectId"

    # Setup Secrets for Credentials
    az keyvault secret set \
        --vault-name "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        -n "azure-client-id" \
        --value "$spAppId" \
        --query '{attributes:attributes, contentType:contentType, id:id, kid:kid, managed:managed, name:name, tags:tags}'

    az keyvault secret set \
        --vault-name "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        -n "azure-client-object-id" \
        --value "$spObjectId" \
        --query '{attributes:attributes, contentType:contentType, id:id, kid:kid, managed:managed, name:name, tags:tags}'

    az keyvault secret set \
        --vault-name "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        -n "azure-client-secret" \
        --value "$spPassword" \
        --query '{attributes:attributes, contentType:contentType, id:id, kid:kid, managed:managed, name:name, tags:tags}'

    az keyvault secret set \
        --vault-name "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        -n "azure-subscription-id" \
        --value "$SUBSCRIPTION_ID" \
        --query '{attributes:attributes, contentType:contentType, id:id, kid:kid, managed:managed, name:name, tags:tags}'

    az keyvault secret set \
        --vault-name "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        -n "azure-tenant-id" \
        --value "$spTenantId" \
        --query '{attributes:attributes, contentType:contentType, id:id, kid:kid, managed:managed, name:name, tags:tags}'

    az keyvault secret set \
        --vault-name "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        -n "admin-password" \
        --value "$ADMIN_PASSWORD" \
        --query '{attributes:attributes, contentType:contentType, id:id, kid:kid, managed:managed, name:name, tags:tags}'

    az keyvault secret set \
        --vault-name "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        -n "admin-password-jumpbox" \
        --value "$ADMIN_PASSWORD_JUMPBOX" \
        --query '{attributes:attributes, contentType:contentType, id:id, kid:kid, managed:managed, name:name, tags:tags}'

    az keyvault secret set \
        --vault-name "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        -n "admin-user" \
        --value "$ADMIN_USER" \
        --query '{attributes:attributes, contentType:contentType, id:id, kid:kid, managed:managed, name:name, tags:tags}'

    az keyvault secret set \
        --vault-name "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        -n "admin-user-jumpbox" \
        --value "$ADMIN_USER_JUMPBOX" \
        --query '{attributes:attributes, contentType:contentType, id:id, kid:kid, managed:managed, name:name, tags:tags}'

    az keyvault secret set \
        --vault-name "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        -n "ado-pat" \
        --value "$ADO_PAT" \
        --query '{attributes:attributes, contentType:contentType, id:id, kid:kid, managed:managed, name:name, tags:tags}'

    az keyvault secret set \
        --vault-name "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        -n "azure-storage-account-key" \
        --value "$ACCOUNT_KEY" \
        --query '{attributes:attributes, contentType:contentType, id:id, kid:kid, managed:managed, name:name, tags:tags}'

    az keyvault secret set \
        --vault-name "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
        -n "omop-password" \
        --value "$OMOP_PASSWORD" \
        --query '{attributes:attributes, contentType:contentType, id:id, kid:kid, managed:managed, name:name, tags:tags}'
else
    PORTER_BOOTSTRAP_AZURE_KEY_VAULT=""
fi

#################################################
###### Setup Porter with bootstrap settings #####
#################################################

echo "Setup Porter with your bootstrap settings for your OHDSI on Azure environment"
bash "${PWD}/setup-porter.sh" "$@" \
    --ARM_CLIENT_ID "$spAppId" \
    --ARM_CLIENT_OBJECT_ID "$spObjectId" \
    --ARM_CLIENT_SECRET "$spPassword" \
    --ARM_TENANT_ID "$spTenantId" \
    --ARM_SUBSCRIPTION_ID "$SUBSCRIPTION_ID" \
    --BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME "$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME" \
    --BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME "$BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME" \
    --BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_CONTAINER_NAME "$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_CONTAINER_NAME" \
    --BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_KEY "$ACCOUNT_KEY" \
    --BOOTSTRAP_TF_BACKEND_FILENAME "$BOOTSTRAP_TF_BACKEND_FILENAME" \
    --PORTER_BOOTSTRAP_AZURE_KEY_VAULT "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT" \
    --ADO_ORGANIZATION_NAME "$ADO_ORGANIZATION_NAME" \
    --ADO_PAT "$ADO_PAT" \
    --OMOP_PASSWORD "$OMOP_PASSWORD" \
    --ADMIN_USER_JUMPBOX "$ADMIN_USER_JUMPBOX" \
    --ADMIN_PASSWORD_JUMPBOX "$ADMIN_PASSWORD_JUMPBOX" \
    --ADMIN_USER "$ADMIN_USER" \
    --ADMIN_PASSWORD "$ADMIN_PASSWORD" \
    --PREFIX "$PREFIX" \
    --ENVIRONMENT "$ENVIRONMENT" \
    --SOURCE_VOCABULARIES_STORAGE_ACCOUNT_NAME "$SOURCE_VOCABULARIES_STORAGE_ACCOUNT_NAME" \
    --SOURCE_VOCABULARIES_STORAGE_ACCOUNT_CONTAINER "$SOURCE_VOCABULARIES_STORAGE_ACCOUNT_CONTAINER" \
    --VOCABULARIES_CONTAINER_NAME "$VOCABULARIES_CONTAINER_NAME" \
    --VOCABULARIES_CONTAINER_PATH "$VOCABULARIES_CONTAINER_PATH" \
    --VOCABULARIES_SEARCH_PATTERN "$VOCABULARIES_SEARCH_PATTERN" \
    --CHECK_RETRY_COUNT "$CHECK_RETRY_COUNT" \
    --CHECK_SECONDS "$CHECK_SECONDS" \
    --INCLUDE_DEBUGGING_OUTPUT "$INCLUDE_DEBUGGING_OUTPUT" \
    --INCLUDE_KEY_VAULT_PORTER_SECRETS "$INCLUDE_KEY_VAULT_PORTER_SECRETS" \
    --BROADSEA_BUILD_PIPELINE_NAME "$BROADSEA_BUILD_PIPELINE_NAME" \
    --BROADSEA_RELEASE_PIPELINE_NAME "$BROADSEA_RELEASE_PIPELINE_NAME" \
    --ENVIRONMENT_DESTROY_PIPELINE_NAME "$ENVIRONMENT_DESTROY_PIPELINE_NAME" \
    --ENVIRONMENT_PIPELINE_NAME "$ENVIRONMENT_PIPELINE_NAME" \
    --LOG_SEARCH_PATTERN "$LOG_SEARCH_PATTERN" \
    --PIPELINE_BRANCH_NAME "$PIPELINE_BRANCH_NAME" \
    --VOCABULARY_BUILD_PIPELINE_NAME "$VOCABULARY_BUILD_PIPELINE_NAME" \
    --VOCABULARY_RELEASE_PIPELINE_NAME "$VOCABULARY_RELEASE_PIPELINE_NAME"
