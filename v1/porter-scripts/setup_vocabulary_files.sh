#!/usr/bin/env bash
# set -u not included to allow unbound variables
set -eo pipefail

ARM_CLIENT_ID=${ARM_CLIENT_ID:-my azure client id}
ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET:-my azure client secret}
ARM_TENANT_ID=${ARM_TENANT_ID:-my azure tenant id}
ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID:-my azure subscription id}
VOCABULARIES_CONTAINER_PATH=${VOCABULARIES_CONTAINER_PATH:-vocabularies\\19-AUG-2021}
STORAGE_ACCOUNT_NAME=${STORAGE_ACCOUNT_NAME:-prefixenvomopsa}
RESOURCE_GROUP_NAME=${RESOURCE_GROUP_NAME:-prefix-environment-omop-rg}
VOCABULARIES_CONTAINER_NAME=${VOCABULARIES_CONTAINER_NAME:-vocabularies}
VOCABULARIES_SEARCH_PATTERN=${VOCABULARIES_SEARCH_PATTERN:-19-AUG-2021\*.csv}
SOURCE_VOCABULARIES_STORAGE_ACCOUNT_NAME=${SOURCE_VOCABULARIES_STORAGE_ACCOUNT_NAME:-demovocabohdsionazure}
SOURCE_VOCABULARIES_STORAGE_ACCOUNT_CONTAINER=${SOURCE_VOCABULARIES_STORAGE_ACCOUNT_CONTAINER:-vocabularies}

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

STORAGE_ACCOUNT_KEY=$(az storage account keys list --resource-group "$RESOURCE_GROUP_NAME" --account-name "$STORAGE_ACCOUNT_NAME" --query '[0].value' -o tsv)

echo "------------------------ SMOKE TEST: VALIDATE VOCAB FILES ------------------------"
# shellcheck disable=SC2116,SC2296
vocabContainerPath=$(echo "$VOCABULARIES_CONTAINER_PATH")
# This assumes that the vocabularies have a form of vocabularies/some/path e.g. vocabularies/02-SEP-21
# shellcheck disable=SC2207,SC2086
vocabContainerPathArr=($(echo $vocabContainerPath | tr "/" "\n"))
# shellcheck disable=SC2116,SC2086
vocabContainerName=$(echo ${vocabContainerPathArr[0]})
vocabPrefix=""
if [ ${#vocabContainerPathArr[*]} -gt 1 ]; then
  printf -v vocabPrefix "%s/" "${vocabContainerPathArr[@]:1}"
  vocabPrefix=${vocabPrefix%?} # remove last character
else
  echo "Unable to detect rest of vocabulary container path, so will proceed with searching for an empty string"
fi
echo "Searching for Prefix $vocabPrefix in Container $vocabContainerName"
# sanity check
az storage blob list -c "$vocabContainerName" --account-name "$STORAGE_ACCOUNT_NAME" --prefix "$vocabPrefix" -o tsv
# shellcheck disable=SC2207
blobArr=($(az storage blob list -c "$vocabContainerName" --account-name "$STORAGE_ACCOUNT_NAME" --prefix "$vocabPrefix" | jq '.[].name'))
# shellcheck disable=SC2128,SC2086
echo $blobArr
if [ ${#blobArr[*]} -gt 0 ]; then
  echo 'Vocabulary files exists, skipping vocabulary files copy'
else
  echo "Vocabulary files not found!"
  echo "Could not find vocabulary files in vocabContainerPath $vocabContainerPath in the storage account"
  echo "Proceeding to copy files from demo vocabulries azure storage account"
  # Copy vocabulary files from the demo storage account into environment storage account
  # Note the pattern will be after the container name e.g. 10-SEP-21\* will match the virtual folder in the vocabularies container
  # Note that in this case the demo storage account is public, so you don't need to include
  # the --source-account-key
  # You can specify storage account credentials if you are using a private Azure Storage Account

  az storage blob copy start-batch \
    --account-key "$STORAGE_ACCOUNT_KEY" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --destination-container "$VOCABULARIES_CONTAINER_NAME" \
    --pattern "$VOCABULARIES_SEARCH_PATTERN" \
    --source-account-name "$SOURCE_VOCABULARIES_STORAGE_ACCOUNT_NAME" \
    --source-container "$SOURCE_VOCABULARIES_STORAGE_ACCOUNT_CONTAINER"
fi
