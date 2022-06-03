#!/usr/bin/env bash
set -euo pipefail

ARM_CLIENT_ID=${ARM_CLIENT_ID:-my azure client id}
ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET:-my azure client secret}
ARM_TENANT_ID=${ARM_TENANT_ID:-my azure tenant id}
ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID:-my azure subscription id}
BUILD_ID=${BUILD_ID:0}
ADO_ORGANIZATION_NAME=${ADO_ORGANIZATION_NAME:-https://dev.azure.com/my-ado-org/}
ADO_PROJECT_NAME=${ADO_PROJECT_NAME:-OHDSIOnAzure}
ADO_PAT=${ADO_PAT:-mypat}
CHECK_SECONDS=${CHECK_SECONDS:-60}
CHECK_RETRY_COUNT=${CHECK_RETRY_COUNT:-20}
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

result=""
status=""
CURRENT_COUNT=0

while [[ "$CURRENT_COUNT" -lt "$CHECK_RETRY_COUNT" ]]; do
  az pipelines runs show \
      --id "$BUILD_ID" \
      --org "$ADO_ORGANIZATION_NAME" \
      --project "$ADO_PROJECT_NAME" \
      --subscription "$ARM_SUBSCRIPTION_ID" \
      > runResult.json

  runResultJson=$(jq < runResult.json)

  rm -rf runResult.json

  if [[ $INCLUDE_DEBUGGING_OUTPUT == "1" ]];
  then
      echo "$runResultJson"
  fi
  
  # succeeded, canceled, failed
  result=$(echo "$runResultJson" | jq -r .result)

  # completed, in progress, not started
  status=$(echo "$runResultJson" | jq -r .status)

  echo "Pipeline for build id $BUILD_ID has result $result and status $status"

  if [[ "$result" == "succeeded" ]] || [[ "$result" == "canceled" ]] || [[ "$status" == "completed" ]]; then
    echo "Pipeline for build id $BUILD_ID has finished"
    break
  fi

  echo "Pipeline for build id $BUILD_ID has not finished, sleeping $CHECK_SECONDS"
  CURRENT_COUNT=$((CURRENT_COUNT+1))
  sleep "$CHECK_SECONDS"
done

