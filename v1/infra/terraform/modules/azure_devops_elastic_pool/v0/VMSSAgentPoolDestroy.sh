#!/bin/bash

# Workaround: TF doesn't have the Azure DevOps 6.1 API so this is a placeholder until the TF provider is updated
# https://github.com/MicrosoftDocs/vsts-rest-api-specs/tree/master/specification/distributedTask/6.1

# set from Environment variables
set -- "${PAT}" "$@"
set -- "${ADO_ORG_SERVICE_URL}" "$@"
set -- "${POOLNAME}" "$@"

# or can set from command line
while [[ $# -gt 0 ]]
do
 # shellcheck disable=SC2154
 case "$1" in
 -p|--PAT)
    PAT=$2
    shift
    ;; # this is your Azure DevOps PAT

 -a|--adoOrgServiceUrl) 
    ADO_ORG_SERVICE_URL=$2
    shift
    ;; # this is something like https://dev.azure.com/<myorg>

 -n|--poolname)
    POOLNAME=$2
    shift
    ;; # Desired Elastic Pool Name
 
 *) echo "Option $opt needs a valid argument"
    ;;
 esac
 shift
done

B64_PAT=$(printf "%s" ":$PAT" | base64)

poolContentJson=$(curl -X GET \
"$ADO_ORG_SERVICE_URL/_apis/distributedtask/pools/?poolName=$POOLNAME&api-version=6.1-preview.1" \
-H "Content-Type: application/json" \
-H "Authorization: Basic $B64_PAT" | jq)
poolCount=$(echo "$poolContentJson" | jq -r .count)

if [ "$poolCount" -gt 0 ]
then
   echo "Found Agent Pool with poolName $POOLNAME"

   poolId=$(echo "$poolContentJson" | jq -r .value[0].id)
   echo "Found Agent Pool with poolName $POOLNAME and poolId $poolId"

   echo "Deleting Agent Pool with poolName $POOLNAME and poolId $poolId"
   curl -X DELETE "$ADO_ORG_SERVICE_URL/_apis/distributedtask/pools/$poolId?api-version=6.1-preview.1" \
   -H "Content-Type: application/json" \
   -H "Authorization: Basic $B64_PAT"
   echo "Deleted Agent Pool with poolName $POOLNAME and poolId $poolId"
else
   echo "Did not find Agent Pool with poolName $POOLNAME, so skipping delete"
fi
