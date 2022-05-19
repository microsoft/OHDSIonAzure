#!/bin/bash
echo 'Start Porter Setup'

########################################
###### Backend Bootstrap Settings ######
########################################

# Backend Storage Settings for Bootstrap Backend, should be passed in
ARM_CLIENT_ID=${ARM_CLIENT_ID:-my azure client id}
ARM_CLIENT_OBJECT_ID=${ARM_CLIENT_OBJECT_ID:-my azure client object id}
ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET:-my azure client secret}
ARM_TENANT_ID=${ARM_TENANT_ID:-my azure tenant id}
ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID:-my azure subscription id}
BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME=${BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME:-bootstraptfstatesa}
BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME=${BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME:-bootstrap-tf-state-rg}
BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_CONTAINER_NAME=${BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_CONTAINER_NAME:-prefix-environment-tfstate}
BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_KEY=${BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_KEY:-prefix-environment-tfstate-sa-key}
BOOTSTRAP_TF_BACKEND_FILENAME=${BOOTSTRAP_TF_BACKEND_FILENAME:-terraform.tfstate}
PORTER_BOOTSTRAP_AZURE_KEY_VAULT=${PORTER_BOOTSTRAP_AZURE_KEY_VAULT:-prefix-environment-kv}

####################################
###### Setup Bootstrap Values ######
####################################

# Additional Configuration for OHDSI on Azure (bootstrap / omop), should be passed in
ADO_ORGANIZATION_NAME=${ADO_ORGANIZATION_NAME:-my-ado-org-name}
ADO_PAT=${ADO_PAT:-your Azure DevOps PAT}
OMOP_PASSWORD=${OMOP_PASSWORD:-replaceMyP4SSW0RD.}
ADMIN_USER_JUMPBOX=${ADMIN_USER_JUMPBOX:-azureuser}
ADMIN_PASSWORD_JUMPBOX=${ADMIN_PASSWORD_JUMPBOX:-replaceYourJumpboxP4SSW0RD.}
ADMIN_USER=${ADMIN_USER:-azureuser}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-replaceYourVMSSP4SSW0RD.}
PREFIX=${PREFIX:-ohdsi}
ENVIRONMENT=${ENVIRONMENT:-dev00}

############################
###### Default Values ######
############################

# Include debugging output, set to 1 to enable
INCLUDE_DEBUGGING_OUTPUT=${INCLUDE_DEBUGGING_OUTPUT:-0}

# Include Key Vault secrets, set to 1 to enable
INCLUDE_KEY_VAULT_PORTER_SECRETS=${INCLUDE_KEY_VAULT_PORTER_SECRETS:-1}

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

##########################
###### Setup Porter ######
##########################

DOS2UNIX_LOCATION=$(which dos2unix)

if [ -z "$DOS2UNIX_LOCATION" ]
then
     echo "Cannot find dos2unix, so using tr to setup porter"
     # Setup Porter
     # Save the porter install
     curl -L https://cdn.porter.sh/latest/install-linux.sh | \
     tr -d '\r' | \
     bash && \
     export PATH=$PATH:~/.porter     
else
     echo "Found dos2unix, so using dos2unix to setup porter"
     # Setup Porter
     curl -L https://cdn.porter.sh/latest/install-linux.sh | \
     dos2unix | \
     bash && \
     export PATH=$PATH:~/.porter
fi

###################################
###### Install Porter Mixins ######
###################################

porter mixin install docker
porter mixin install az
porter mixin install exec
porter mixin install terraform

####################################
###### Install Porter Plugins ######
####################################

porter plugin install azure

################################################
###### Setup Porter Environment Variables ######
###### For your Credentials and parameters #####
################################################

export AZURE_DEVOPS_EXT_PAT="$ADO_PAT"

# Porter Credentials
export AZURE_TENANT_ID="$ARM_TENANT_ID"
export AZURE_SUBSCRIPTION_ID="$ARM_SUBSCRIPTION_ID"
export AZURE_CLIENT_ID="$ARM_CLIENT_ID"
export AZURE_CLIENT_OBJECT_ID="$ARM_CLIENT_OBJECT_ID"
export AZURE_CLIENT_SECRET="$ARM_CLIENT_SECRET"
export AZURE_STORAGE_ACCOUNT_KEY="$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_KEY"
export OMOP_PASSWORD="$OMOP_PASSWORD"
export ADO_PAT="$ADO_PAT"
export ADMIN_USER_JUMPBOX="$ADMIN_USER_JUMPBOX"
export ADMIN_PASSWORD_JUMPBOX="$ADMIN_PASSWORD_JUMPBOX"
export ADMIN_USER="$ADMIN_USER"
export ADMIN_PASSWORD="$ADMIN_PASSWORD"

# Porter Parameters
export PREFIX="$PREFIX"
export ENVIRONMENT="$ENVIRONMENT"

export ADO_ORGANIZATION_NAME="$ADO_ORGANIZATION_NAME"
export ADO_ORGANIZATION_URL="https://dev.azure.com/${ADO_ORGANIZATION_NAME}/"
export ADO_PROJECT_URL="https://dev.azure.com/${ADO_ORGANIZATION_NAME}/${PREFIX}-${ENVIRONMENT}-OHDSIonAzure"
export BROADSEA_BUILD_PIPELINE_NAME="$BROADSEA_BUILD_PIPELINE_NAME"
export BROADSEA_RELEASE_PIPELINE_NAME="$BROADSEA_RELEASE_PIPELINE_NAME"
export CHECK_RETRY_COUNT="$CHECK_RETRY_COUNT"
export CHECK_SECONDS="$CHECK_SECONDS"
export ENVIRONMENT_DESTROY_PIPELINE_NAME="$ENVIRONMENT_DESTROY_PIPELINE_NAME"
export ENVIRONMENT_PIPELINE_NAME="$ENVIRONMENT_PIPELINE_NAME"
export INCLUDE_DEBUGGING_OUTPUT="$INCLUDE_DEBUGGING_OUTPUT"
export LOG_SEARCH_PATTERN="$LOG_SEARCH_PATTERN"
export PIPELINE_BRANCH_NAME="$PIPELINE_BRANCH_NAME"
export SOURCE_VOCABULARIES_STORAGE_ACCOUNT_CONTAINER="$SOURCE_VOCABULARIES_STORAGE_ACCOUNT_CONTAINER"
export SOURCE_VOCABULARIES_STORAGE_ACCOUNT_NAME="$SOURCE_VOCABULARIES_STORAGE_ACCOUNT_NAME"
export TFSTATE_CONTAINER_NAME="$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_CONTAINER_NAME"
export TFSTATE_FILE_NAME="$BOOTSTRAP_TF_BACKEND_FILENAME"
export TFSTATE_RESOURCE_GROUP_NAME="$BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME"
export TFSTATE_STORAGE_ACCOUNT_NAME="$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME"
export VOCABULARIES_CONTAINER_NAME="$VOCABULARIES_CONTAINER_NAME"
export VOCABULARIES_CONTAINER_PATH="$VOCABULARIES_CONTAINER_PATH"
export VOCABULARIES_SEARCH_PATTERN="$VOCABULARIES_SEARCH_PATTERN"

VOCABULARIES_STORAGE_ACCOUNT_NAME="$PREFIX$ENVIRONMENT"
VOCABULARIES_STORAGE_ACCOUNT_NAME+="omopsa"
export VOCABULARIES_STORAGE_ACCOUNT_NAME="$VOCABULARIES_STORAGE_ACCOUNT_NAME"
export VOCABULARY_BUILD_PIPELINE_NAME="$VOCABULARY_BUILD_PIPELINE_NAME"
export VOCABULARY_RELEASE_PIPELINE_NAME="$VOCABULARY_RELEASE_PIPELINE_NAME"

########################################################
###### Setup Porter Azure Key Vault Configuration ######
###### For your Credentials ############################
########################################################

if [[ $INCLUDE_KEY_VAULT_PORTER_SECRETS == "1" ]];
then

cat << EOF > "$HOME/.porter/config.toml"
     default-secrets = "$PREFIX-$ENVIRONMENT-secrets"
     
     [[secrets]]
     name = "$PREFIX-$ENVIRONMENT-secrets"
     plugin = "azure.keyvault"
     
     [secrets.config]
     vault = "$PORTER_BOOTSTRAP_AZURE_KEY_VAULT"
EOF

# Set permissions on porter config.toml 
chmod 600 "$HOME/.porter/config.toml"

fi

################################################
###### Setup Porter Environment Variables ######
###### For your Credentials and parameters #####
###### As a template for sourcing later ########
################################################

cat << EOF > "$PREFIX-$ENVIRONMENT-OHDSIOnAzure.env"
     # Add Porter to Path
     export PATH=\$PATH:~/.porter

     # Setup for Azure DevOps Extension for az cli
     export AZURE_DEVOPS_EXT_PAT="$ADO_PAT"

     # Porter Credentials - You can use environment variables for credentials
     export AZURE_TENANT_ID="$ARM_TENANT_ID"
     export AZURE_SUBSCRIPTION_ID="$ARM_SUBSCRIPTION_ID"
     export AZURE_CLIENT_ID="$ARM_CLIENT_ID"
     export AZURE_CLIENT_OBJECT_ID="$ARM_CLIENT_OBJECT_ID"
     export AZURE_CLIENT_SECRET="$ARM_CLIENT_SECRET"
     export AZURE_STORAGE_ACCOUNT_KEY="$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_KEY"
     export OMOP_PASSWORD="$OMOP_PASSWORD"
     export ADO_PAT="$ADO_PAT"
     export ADMIN_USER_JUMPBOX="$ADMIN_USER_JUMPBOX"
     export ADMIN_PASSWORD_JUMPBOX="$ADMIN_PASSWORD_JUMPBOX"
     export ADMIN_USER="$ADMIN_USER"
     export ADMIN_PASSWORD="$ADMIN_PASSWORD"

     # Porter Parameters
     export PREFIX="$PREFIX"
     export ENVIRONMENT="$ENVIRONMENT"

     export ADO_ORGANIZATION_NAME="$ADO_ORGANIZATION_NAME"
     export ADO_ORGANIZATION_URL="https://dev.azure.com/${ADO_ORGANIZATION_NAME}/"
     export ADO_PROJECT_URL="https://dev.azure.com/${ADO_ORGANIZATION_NAME}/${PREFIX}-${ENVIRONMENT}-OHDSIonAzure"
     export BROADSEA_BUILD_PIPELINE_NAME="$BROADSEA_BUILD_PIPELINE_NAME"
     export BROADSEA_RELEASE_PIPELINE_NAME="$BROADSEA_RELEASE_PIPELINE_NAME"
     export CHECK_RETRY_COUNT="$CHECK_RETRY_COUNT"
     export CHECK_SECONDS="$CHECK_SECONDS"
     export ENVIRONMENT_DESTROY_PIPELINE_NAME="$ENVIRONMENT_DESTROY_PIPELINE_NAME"
     export ENVIRONMENT_PIPELINE_NAME="$ENVIRONMENT_PIPELINE_NAME"
     export INCLUDE_DEBUGGING_OUTPUT="$INCLUDE_DEBUGGING_OUTPUT"
     export LOG_SEARCH_PATTERN="$LOG_SEARCH_PATTERN"
     export PIPELINE_BRANCH_NAME="$PIPELINE_BRANCH_NAME"
     export SOURCE_VOCABULARIES_STORAGE_ACCOUNT_CONTAINER="$SOURCE_VOCABULARIES_STORAGE_ACCOUNT_CONTAINER"
     export SOURCE_VOCABULARIES_STORAGE_ACCOUNT_NAME="$SOURCE_VOCABULARIES_STORAGE_ACCOUNT_NAME"
     export TFSTATE_CONTAINER_NAME="$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_CONTAINER_NAME"
     export TFSTATE_FILE_NAME="$BOOTSTRAP_TF_BACKEND_FILENAME"
     export TFSTATE_RESOURCE_GROUP_NAME="$BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME"
     export TFSTATE_STORAGE_ACCOUNT_NAME="$BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME"
     export VOCABULARIES_CONTAINER_NAME="$VOCABULARIES_CONTAINER_NAME"
     export VOCABULARIES_CONTAINER_PATH="$VOCABULARIES_CONTAINER_PATH"
     export VOCABULARIES_SEARCH_PATTERN="$VOCABULARIES_SEARCH_PATTERN"

     export VOCABULARIES_STORAGE_ACCOUNT_NAME="$VOCABULARIES_STORAGE_ACCOUNT_NAME"
     export VOCABULARY_BUILD_PIPELINE_NAME="$VOCABULARY_BUILD_PIPELINE_NAME"
     export VOCABULARY_RELEASE_PIPELINE_NAME="$VOCABULARY_RELEASE_PIPELINE_NAME"
EOF

# Source your environment
echo "Porter Installation Complete.  You can now configure your environment with the command: source \"$PREFIX-$ENVIRONMENT-OHDSIOnAzure.env\""
# shellcheck disable=SC1090
source "$PREFIX-$ENVIRONMENT-OHDSIOnAzure.env"