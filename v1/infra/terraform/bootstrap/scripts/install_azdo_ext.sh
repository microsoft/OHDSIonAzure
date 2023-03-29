#!/bin/bash
set -- "${PAT}" "$@"
set -- "${ADO_ORG_SERVICE_URL}" "$@"
set -- "${ADO_PROJECT_NAME}" "$@"

export AZURE_DEVOPS_EXT_PAT="$PAT"

echo "$ADO_ORG_SERVICE_URL"

# your ADO PAT needs to be authorized to install and manage extensions
echo 'Attempt to configure ADO settings'
az devops configure --defaults "organization=$ADO_ORG_SERVICE_URL" "project=$ADO_PROJECT_NAME"

if az devops extension list | grep "charleszipp.azure-pipelines-tasks-terraform"; then
   echo "Terraform extension exists."
else
   echo "Terraform extension does not exists. Attempting to install..."
   az devops extension install --publisher-id 'charleszipp' --extension-id 'azure-pipelines-tasks-terraform'
fi
