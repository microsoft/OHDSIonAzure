#!/usr/bin/env bash
set -euo pipefail

ARM_CLIENT_ID=${ARM_CLIENT_ID:-my azure client id}
ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET:-my azure client secret}
ARM_TENANT_ID=${ARM_TENANT_ID:-my azure tenant id}
ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID:-my azure subscription id}
BRANCH=${BRANCH:-refs/heads/main}
PIPELINE_NAME=${PIPELINE_NAME:-TF Apply OMOP Environment Pipeline}
ADO_ORGANIZATION_NAME=${ADO_ORGANIZATION_NAME:-https://dev.azure.com/my-ado-org/}
ADO_PROJECT_NAME=${ADO_PROJECT_NAME:-OHDSIOnAzure}
FOLDER_PATH=${FOLDER_PATH:-OHDSIOnAzure\\prefix-environment\\SomeFolder}
ADO_PAT=${ADO_PAT:-mypat}

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare "$param"="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

export ARM_CLIENT_ID="$ARM_CLIENT_ID"
export ARM_CLIENT_SECRET="$ARM_CLIENT_SECRET"
export ARM_TENANT_ID="$ARM_TENANT_ID"
export ARM_SUBSCRIPTION_ID="$ARM_SUBSCRIPTION_ID"

export AZURE_DEVOPS_EXT_PAT="$ADO_PAT"
az devops configure --defaults organization="$ADO_ORGANIZATION_NAME"

runResult=$(az pipelines run \
    --branch "$BRANCH" \
    --folder-path "$FOLDER_PATH" \
    --name "$PIPELINE_NAME" \
    --org "$ADO_ORGANIZATION_NAME" \
    --project "$ADO_PROJECT_NAME" \
    --subscription "$ARM_SUBSCRIPTION_ID")

echo "$runResult"