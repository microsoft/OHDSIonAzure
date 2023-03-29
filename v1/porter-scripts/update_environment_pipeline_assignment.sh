#!/usr/bin/env bash
set -euo pipefail

ARM_CLIENT_ID=${ARM_CLIENT_ID:-my azure client id}
ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET:-my azure client secret}
ARM_TENANT_ID=${ARM_TENANT_ID:-my azure tenant id}
ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID:-my azure subscription id}
PIPELINE_NAME=${PIPELINE_NAME:-TF Apply OMOP Environment Pipeline}
ADO_ENVIRONMENT_NAME=${ADO_ENVIRONMENT_NAME:-prefix-environment-omop-tf-plan-environment}
ADO_ORGANIZATION_NAME=${ADO_ORGANIZATION_NAME:-https://dev.azure.com/my-ado-org/}
ADO_PROJECT_NAME=${ADO_PROJECT_NAME:-OHDSIOnAzure}
FOLDER_PATH=${FOLDER_PATH:-OHDSIOnAzure\\prefix-environment\\SomeFolder}
ADO_PAT=${ADO_PAT:-mypat}
AUTHORIZED=${AUTHORIZED:-true}
INCLUDE_DEBUGGING_OUTPUT=${INCLUDE_DEBUGGING_OUTPUT:-0}

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

B64_PAT=$(printf "%s" ":$ADO_PAT" | base64)
PIPELINE_ID=$( az pipelines show --name "$PIPELINE_NAME" --folder-path "$FOLDER_PATH" \
  -p "$ADO_PROJECT_NAME" --org "$ADO_ORGANIZATION_NAME" \
  --query "id" -o tsv)

generate_request_body()
{
  cat <<EOF
{
  "pipelines": [
    {
      "id": $PIPELINE_ID,
      "authorized": $AUTHORIZED
    }
  ]
}
EOF
}

ENVIRONMENT_ID=$(curl -X GET "$ADO_ORGANIZATION_NAME/$ADO_PROJECT_NAME/_apis/distributedtask/environments/?name=$ADO_ENVIRONMENT_NAME&api-version=6.1-preview.1" \
    -H "Content-Type: application/json" \
    -H "Authorization: Basic $B64_PAT" | jq -r ".value[].id")

result=$(curl -X PATCH "$ADO_ORGANIZATION_NAME/$ADO_PROJECT_NAME/_apis/pipelines/pipelinepermissions/environment/$ENVIRONMENT_ID?api-version=7.1-preview.1" \
-H "Content-Type: application/json" \
-H "Authorization: Basic $B64_PAT" \
--data "$(generate_request_body)")

if [[ $INCLUDE_DEBUGGING_OUTPUT == "1" ]];
then
  echo "Applied assignment for environment $ADO_ENVIRONMENT_NAME for $PIPELINE_NAME, and got result $result"
fi

echo "Finished assigning environment $ADO_ENVIRONMENT_NAME for $PIPELINE_NAME"