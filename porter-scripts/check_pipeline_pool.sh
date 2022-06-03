#!/usr/bin/env bash
set -euo pipefail
ADO_ORGANIZATION_NAME=${ADO_ORGANIZATION_NAME:-https://dev.azure.com/my-ado-org/}
ADO_PROJECT_NAME=${ADO_PROJECT_NAME:-OHDSIOnAzure}
ADO_QUEUE_NAME=${ADO_PROJECT_NAME:-prefix-env-ado-build-vmss-agent-pool}
ADO_PAT=${ADO_PAT:-mypat}
CHECK_SECONDS=${CHECK_SECONDS:-60}
CHECK_RETRY_COUNT=${CHECK_RETRY_COUNT:-10}

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare "$param"="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

export AZURE_DEVOPS_EXT_PAT="$ADO_PAT"
az devops configure --defaults organization="$ADO_ORGANIZATION_NAME"
READY=false
CURRENT_COUNT=0

while [ "$CURRENT_COUNT" -lt "$CHECK_RETRY_COUNT" ]; do
  echo "Checking Agent Pool $ADO_QUEUE_NAME"

  queueJson=$(az pipelines queue list --organization "$ADO_ORGANIZATION_NAME" -p "$ADO_PROJECT_NAME" --query "[?name == '$ADO_QUEUE_NAME']")
  poolId=$(echo "$queueJson" | jq -r '.[].pool.id')

  echo "Got poolId $poolId"

  if [ -z "$poolId" ]; then
    echo "Unable to find poolId for pool $ADO_QUEUE_NAME, sleeping $CHECK_SECONDS"
    CURRENT_COUNT=$((CURRENT_COUNT+1))
    sleep "$CHECK_SECONDS"
    continue
  fi

  # check that the Agent Pool has an online agent
  READY=$(az pipelines agent list --pool-id "$poolId" | jq -r 'any(.[].status=="online"; .)')

  if [ "$READY" = "true" ]; then
    echo "Agent Pool $ADO_QUEUE_NAME has at least one agent ready"
    break
  fi

  echo "Agent Pool $ADO_QUEUE_NAME is not ready, sleeping $CHECK_SECONDS"
  CURRENT_COUNT=$((CURRENT_COUNT+1))
  sleep "$CHECK_SECONDS"
done