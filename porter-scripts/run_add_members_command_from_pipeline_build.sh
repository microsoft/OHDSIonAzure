#!/usr/bin/env bash
set -euo pipefail

ARM_CLIENT_ID=${ARM_CLIENT_ID:-my azure client id}
ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET:-my azure client secret}
ARM_TENANT_ID=${ARM_TENANT_ID:-my azure tenant id}
ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID:-my azure subscription id}
# ADO_ORGANIZATION_NAME should have trailing `/` e.g. https://dev.azure.com/<my-org>/
ADO_ORGANIZATION_NAME=${ADO_ORGANIZATION_NAME:-https://dev.azure.com/my-ado-org/}
ADO_PROJECT_NAME=${ADO_PROJECT_NAME:-OHDSIOnAzure}
BUILD_ID=${BUILD_ID:-1}
ADO_PAT=${ADO_PAT:-mypat}
LOG_SEARCH_PATTERN=${LOG_SEARCH_PATTERN:-Your Administrator should run the following Azure CLI commands as part of your Azure SQL Server setup:}
# Set INCLUDE_DEBUGGING_OUTPUT to 1 if you want to include debugging output
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

az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"

B64_PAT=$(printf "%s"":$ADO_PAT" | base64)

# ADO_ORGANIZATION_NAME should have trailing / e.g. https://dev.azure.com/<my-org>/
LOG_ITEMS=$(curl -X GET "$ADO_ORGANIZATION_NAME$ADO_PROJECT_NAME/_apis/build/builds/$BUILD_ID/logs?api-version=6.0" \
-H "Content-Type: application/json" \
-H "Authorization: Basic $B64_PAT" | jq -r ".[]")

echo "$LOG_ITEMS" > log_items.json

jq -r ".[].id" < log_items.json \
    | xargs -L1 -I'{}' curl -X GET "$ADO_ORGANIZATION_NAME$ADO_PROJECT_NAME/_apis/build/builds/$BUILD_ID/logs/{}" -H "Authorization: Basic $B64_PAT" \
    | grep "$LOG_SEARCH_PATTERN" -A 10 \
    >> ./cur_results.txt

# clean up file
rm log_items.json

# Search for the log search pattern in the intermediate file
# Get the last 10 lines
# Remove the first 33 characters (for the datetime value)
# The end result should look like az ad group member add -g some-guid --member-id some-guid
ADD_MEMBERS_COMMAND=$(grep "$LOG_SEARCH_PATTERN" -A 10 cur_results.txt \
    | tail -10 \
    | cut -c 34-)

# clean up file
rm cur_results.txt

# Write command to file
cat << EOF > ./add_members.sh
#!/bin/bash

$ADD_MEMBERS_COMMAND
EOF

if [[ $INCLUDE_DEBUGGING_OUTPUT == "1" ]];
then
    echo "Running Add Members Command: $ADD_MEMBERS_COMMAND"
fi

# Execute the command
tr -d '\r' < ./add_members.sh | bash

# Clean up file
rm ./add_members.sh
