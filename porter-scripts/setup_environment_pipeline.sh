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
CHECK_SECONDS=${CHECK_SECONDS:-60}
CHECK_RETRY_COUNT=${CHECK_RETRY_COUNT:-20}
LOG_SEARCH_PATTERN=${LOG_SEARCH_PATTERN:-Your Administrator should run the following Azure CLI commands as part of your Azure SQL Server setup:}
INCLUDE_DEBUGGING_OUTPUT=${INCLUDE_DEBUGGING_OUTPUT:0}

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare "$param"="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

echo "Calling Environment Pipeline"
PIPELINE_COMPLETED_RESULT=$(bash ./porter-scripts/run_pipeline_check_completed.sh "$@" \
    --ARM_CLIENT_ID "$ARM_CLIENT_ID" \
    --ARM_CLIENT_SECRET "$ARM_CLIENT_SECRET" \
    --ARM_TENANT_ID "$ARM_TENANT_ID" \
    --ARM_SUBSCRIPTION_ID "$ARM_SUBSCRIPTION_ID" \
    --BRANCH "$BRANCH" \
    --FOLDER_PATH "$FOLDER_PATH" \
    --PIPELINE_NAME "$PIPELINE_NAME" \
    --ADO_ORGANIZATION_NAME "$ADO_ORGANIZATION_NAME" \
    --ADO_PROJECT_NAME "$ADO_PROJECT_NAME" \
    --ADO_PAT "$ADO_PAT" \
    --CHECK_SECONDS "$CHECK_SECONDS" \
    --CHECK_RETRY_COUNT "$CHECK_RETRY_COUNT")

BUILD_ID=$(echo "$PIPELINE_COMPLETED_RESULT" | tail -n 1)

echo "Running Post Terraform Deployment Step for Adding Azure AD Group members"
bash ./porter-scripts/run_add_members_command_from_pipeline_build.sh "$@" \
    --ARM_CLIENT_ID "$ARM_CLIENT_ID" \
    --ARM_CLIENT_SECRET "$ARM_CLIENT_SECRET" \
    --ARM_TENANT_ID "$ARM_TENANT_ID" \
    --ARM_SUBSCRIPTION_ID "$ARM_SUBSCRIPTION_ID" \
    --ADO_ORGANIZATION_NAME "$ADO_ORGANIZATION_NAME" \
    --ADO_PROJECT_NAME "$ADO_PROJECT_NAME" \
    --BUILD_ID "$BUILD_ID" \
    --ADO_PAT "$ADO_PAT" \
    --LOG_SEARCH_PATTERN "$LOG_SEARCH_PATTERN" \
    --INCLUDE_DEBUGGING_OUTPUT "$INCLUDE_DEBUGGING_OUTPUT"
