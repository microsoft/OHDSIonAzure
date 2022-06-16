#!/bin/bash

# Workaround: TF doesn't have the Azure DevOps 6.1 API so this is a placeholder until the TF provider is updated
# https://github.com/MicrosoftDocs/vsts-rest-api-specs/tree/master/specification/distributedTask/6.1

eval "$(jq -r '@sh "PAT=\(.pat) ADO_ORG_SERVICE_URL=\(.adoOrgServiceUrl) POOLNAME=\(.poolname) PROJECT_ID=\(.projectId) SERVICE_ENDPOINT_ID=\(.serviceEndpointId) RESOURCE_ID=\(.resourceId) OS_TYPE=\(.osType) MAX_CAPACITY=\(.maxCapacity) DESIRED_IDLE=\(.desiredIdle) RECYCLE_AFTER_EACH_USE=\(.recycleAfterEachUse) DESIRED_SIZE=\(.desiredSize) TIME_TO_LIVE_MINUTES=\(.timeToLiveMinutes)"')"

generate_request_body()
{
  cat <<EOF
{
  "serviceEndpointId": "$SERVICE_ENDPOINT_ID",
  "serviceEndpointScope": "$PROJECT_ID",
  "azureId": "$RESOURCE_ID",
  "maxCapacity": $MAX_CAPACITY,
  "desiredIdle": $DESIRED_IDLE,
  "recycleAfterEachUse": $RECYCLE_AFTER_EACH_USE,
  "maxSavedNodeCount": 0,
  "osType": "$OS_TYPE",
  "state": "online",
  "desiredSize": $DESIRED_SIZE,
  "sizingAttempts": 0,
  "agentInteractiveUI": false,
  "timeToLiveMinutes": $TIME_TO_LIVE_MINUTES
}
EOF
}

# create b64 encoded PAT
B64_PAT=$(printf "%s"":$PAT" | base64)

createVMSSResult=$(curl -X POST "$ADO_ORG_SERVICE_URL/_apis/distributedtask/elasticpools?api-version=6.1-preview.1&poolName=$POOLNAME&authorizeAllPipelines=false&autoProvisionProjectPools=false&projectId=$PROJECT_ID" \
-H "Content-Type: application/json" \
-H "Authorization: Basic $B64_PAT" \
--data "$(generate_request_body)")

cat << EOF > "$POOLNAME-$OS_TYPE-RESULT.txt"
  $createVMSSResult
EOF

createVMSSJson=$(jq . "$POOLNAME-$OS_TYPE-RESULT.txt")
cat << EOF > "$POOLNAME-$OS_TYPE-RESULT.json"
  $createVMSSJson
EOF

# extract values for use later
echo "$createVMSSJson" | \
  jq '(.agentQueue.id|tostring) as $agentQueueId | (.agentPool.id|tostring) as $agentPoolId |(.elasticPool.poolId|tostring) as $elasticPoolId | { "elastic_pool_id": $elasticPoolId, "agent_queue_id": $agentQueueId, "agent_pool_id": $agentPoolId }'