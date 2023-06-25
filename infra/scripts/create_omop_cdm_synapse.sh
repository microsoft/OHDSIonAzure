#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

LOG_FILE=${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/all.log

exec >  >(tee -ia "${LOG_FILE}")
exec 2> >(tee -ia "${LOG_FILE}" >&2)

apk --update add gettext gnupg

# Download the desired package(s)
curl -O https://download.microsoft.com/download/1/f/f/1fffb537-26ab-4947-a46a-7a45c27f6f77/msodbcsql18_18.2.1.1-1_amd64.apk
curl -O https://download.microsoft.com/download/1/f/f/1fffb537-26ab-4947-a46a-7a45c27f6f77/mssql-tools18_18.2.1.1-1_amd64.apk

curl -O https://download.microsoft.com/download/1/f/f/1fffb537-26ab-4947-a46a-7a45c27f6f77/msodbcsql18_18.2.1.1-1_amd64.sig
curl -O https://download.microsoft.com/download/1/f/f/1fffb537-26ab-4947-a46a-7a45c27f6f77/mssql-tools18_18.2.1.1-1_amd64.sig

curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import -
gpg --verify msodbcsql18_18.2.1.1-1_amd64.sig msodbcsql18_18.2.1.1-1_amd64.apk
gpg --verify mssql-tools18_18.2.1.1-1_amd64.sig mssql-tools18_18.2.1.1-1_amd64.apk

# Install the package(s)
apk add --allow-untrusted msodbcsql18_18.2.1.1-1_amd64.apk
apk add --allow-untrusted mssql-tools18_18.2.1.1-1_amd64.apk

PATH="$PATH:/opt/mssql-tools18/bin"


printf 'Creating schemas\n'
# shellcheck disable=SC2154
echo "$SQL_create_omop_schemas" | envsubst | sqlcmd -I -b

sed -i s/@cdmDatabaseSchema/"${OMOP_CDM_SCHEMA_NAME}"/g OMOPCDM_synapse_5.4_ddl.sql

# create OMOP CDM (+ Vocabulary) tables
printf 'Creating OMOP CDM tables\n'
sqlcmd -I -b -i OMOPCDM_synapse_5.4_ddl.sql

# create OMOP Results (Achilles) tables
printf 'Creating OMOP Results tables\n'
# shellcheck disable=SC2154
echo "$SQL_create_achilles_tables" | envsubst | sqlcmd -I -b

# create OMOP CDM primary keys
# printf 'Creating OMOP CDM primary keys\n'
# psql "$OMOP_CONNECTION_STRING" -e -f OMOPCDM_postgresql_5.4_primary_keys.sql -v ON_ERROR_STOP=1

# load ODOM data
tables=("cdm.concept_ancestor" "cdm.concept_relationship" "cdm.concept" "cdm.drug_strength" "cdm.concept_synonym" "cdm.measurement" "cdm.observation" "cdm.cost" "cdm.visit_detail" "cdm.visit_occurrence" "cdm.payer_plan_period" "cdm.drug_exposure" "cdm.procedure_occurrence" "cdm.condition_occurrence" "cdm.condition_era" "cdm.provider" "cdm.drug_era" "cdm.person" "cdm.relationship" "cdm.observation_period" "cdm.concept_class" "cdm.device_exposure" "cdm.death" "cdm.cdm_source" "cdm.vocabulary" "cdm.domain" "cdm_results.achilles_analysis" "cdm_results.achilles_results_dist" "cdm_results.achilles_results")
printf 'Loading OMOP data\n'
n=${#tables[@]}
i=0
for element in "${tables[@]}"; do
    ((i++)) || true
    printf "Importing %s (%s)\n" "$element.csv.gz" "$i/$n"        
    sqlcmd -I -b -Q "COPY INTO $element FROM '${OMOP_CDM_CONTAINER_URL}$element.csv.gz${OMOP_CDM_SAS_TOKEN}' WITH (FILE_TYPE = 'CSV', COMPRESSION = 'gzip')"
    echo "exit code $?"
done


# create OMOP CDM indices
# printf 'creating OMOP CDM indices\n'
# psql "$OMOP_CONNECTION_STRING" -e -f OMOPCDM_postgresql_5.4_indices.sql -v ON_ERROR_STOP=1
# for now user will need to add a source via Atlas UI, there's work in progress to automate this

printf 'OMOP CDM created, you can now add it to Atlas as a source, connection string will avaiable in Azure KeyVault.\n'
