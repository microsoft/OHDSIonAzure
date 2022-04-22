#!/bin/bash

# Workaround: TF doesn't have the Azure DevOps 7.1 API so this is a placeholder until the TF provider is updated
# https://github.com/MicrosoftDocs/vsts-rest-api-specs/tree/master/specification/distributedTask/7.1

# Get from environment variables
set -- "${PAT}" "$@"
set -- "${ADO_ORG_SERVICE_URL}" "$@"
set -- "${ADO_PROJECT_NAME}" "$@"
set -- "${QUEUE_ID}" "$@"
set -- "${PIPELINE_ID}" "$@"
set -- "${AUTHORIZED}" "$@"

# read from query
eval "$(jq -r '@sh "PAT=\(.pat) ADO_ORG_SERVICE_URL=\(.adoOrgServiceUrl) ADO_PROJECT_NAME=\(.adoProjectName) QUEUE_ID=\(.adoQueueId) PIPELINE_ID=\(.adoPipelineId) AUTHORIZED=\(.authorized)"')"

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

B64_PAT=$(printf "%s"":$PAT" | base64)

resultJson=$(curl -X PATCH "$ADO_ORG_SERVICE_URL/$ADO_PROJECT_NAME/_apis/pipelines/pipelinepermissions/queue/$QUEUE_ID?api-version=7.1-preview.1" \
-H "Content-Type: application/json" \
-H "Authorization: Basic $B64_PAT" \
--data "$(generate_request_body)" | jq )

# extract values for use later
# output doesn't let you return an array, so convert authorized pipeline ids into a CSV
authorizedPipelineIds=$(echo "$resultJson" | jq '(.pipelines[].id|tostring) ' | paste -s -d, -)

jq -n --arg authorizedPipelineIds "$authorizedPipelineIds" '{"authorized_pipeline_ids":$authorizedPipelineIds}'