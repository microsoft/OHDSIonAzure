#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

LOG_FILE=${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/all.log

exec >  >(tee -ia "${LOG_FILE}")
exec 2> >(tee -ia "${LOG_FILE}" >&2)

# install postgresql client
echo 'installing psql...'
apk --update add postgresql-client gettext

# create OMOP CDM schema and user
pg_cdm_password="${POSTGRES_OMOP_CDM_PASSWORD}${POSTGRES_CDM_USERNAME}"
CDM_MD5=$(echo -n "$pg_cdm_password" | md5sum | awk '{ print $1 }')
export CDM_MD5="'md5$CDM_MD5'"

printf 'Creating omp cdm schemas and user\n'
# shellcheck disable=SC2154
echo "$SQL_create_omop_schemas" | envsubst | psql "$OMOP_CONNECTION_STRING" -e

# create OMOP CDM (+ Vocabulary) tables
printf 'Creating OMOP CDM tables\n'
sed -i  s/@cdmDatabaseSchema/"${POSTGRES_OMOP_CDM_SCHEMA_NAME}"/g OMOPCDM_postgresql_5.4_ddl.sql OMOPCDM_postgresql_5.4_constraints.sql OMOPCDM_postgresql_5.4_primary_keys.sql OMOPCDM_postgresql_5.4_indices.sql
psql "$OMOP_CONNECTION_STRING" -e -f OMOPCDM_postgresql_5.4_ddl.sql -v ON_ERROR_STOP=1

# create and load OMOP Results (Achilles) tables
printf 'Creating OMOP Results tables\n'
# shellcheck disable=SC2154
echo "$SQL_create_achilles_schema" | envsubst | psql "$OMOP_CONNECTION_STRING" -e -v ON_ERROR_STOP=1

# skip foreign key constraints for now due to open bug - https://github.com/OHDSI/CommonDataModel/issues/452
# psql "$OMOP_CONNECTION_STRING" -f OMOPCDM_postgresql_5.4_constraints.sql
# create OMOP CDM primary keys
printf 'Creating OMOP CDM primary keys\n'
psql "$OMOP_CONNECTION_STRING" -e -f OMOPCDM_postgresql_5.4_primary_keys.sql -v ON_ERROR_STOP=1
# load OMOP CDM data
tables=("cdm.concept_ancestor" "cdm.concept_relationship" "cdm.concept" "cdm.drug_strength" "cdm.concept_synonym" "cdm.measurement" "cdm.observation" "cdm.cost" "cdm.visit_detail" "cdm.visit_occurrence" "cdm.payer_plan_period" "cdm.drug_exposure" "cdm.procedure_occurrence" "cdm.condition_occurrence" "cdm.condition_era" "cdm.provider" "cdm.drug_era" "cdm.person" "cdm.relationship" "cdm.observation_period" "cdm.concept_class" "cdm.device_exposure" "cdm.death" "cdm.cdm_source" "cdm.vocabulary" "cdm.domain" "cdm_results.achilles_analysis" "cdm_results.achilles_results_dist" "cdm_results.achilles_results")
printf 'Loading OMOP CDM data\n'
n=${#tables[@]}
i=0
for element in "${tables[@]}"; do
    ((i++)) || true
    printf "Downloading and extracting: %s (%s)\n" "$element.csv.gz" "$i/$n"
    file=/tmp/"$element".csv
    curl "${OMOP_CDM_CONTAINER_URL}$element.csv.gz${OMOP_CDM_SAS_TOKEN}" | gunzip > "$file"
    num_of_records=$(wc -l "$file" | awk '{print $1}')
    printf "Copying %s records to table: %s\n" "$num_of_records" "$element"
    psql "$OMOP_CONNECTION_STRING" -c "\COPY $element FROM '$file' WITH CSV;" -v ON_ERROR_STOP=1
    rm -f "$file"
    printf "done\n"
done

# create OMOP CDM indices
printf 'creating OMOP CDM indices\n'
psql "$OMOP_CONNECTION_STRING" -e -f OMOPCDM_postgresql_5.4_indices.sql -v ON_ERROR_STOP=1

# Generate results DDL
wget -O OMOP_RESULTS_DDL.sql "${OHDSI_WEBAPI_URL}ddl/results?dialect=postgresql&schema=$POSTGRES_OMOP_RESULTS_SCHEMA_NAME&vocabSchema=$POSTGRES_OMOP_CDM_SCHEMA_NAME&tempSchema=$POSTGRES_OMOP_TEMP_SCHEMA_NAME&initConceptHierarchy=true"

# Execute results DDL
psql "$OMOP_CONNECTION_STRING" -e -f OMOP_RESULTS_DDL.sql -v ON_ERROR_STOP=1

# for now user will need to add a source via Atlas UI, there's work in progress to automate this
printf 'OMOP CDM created, you can now add it to Atlas as a source, connection string will avaiable in Azure KeyVault.\n'
