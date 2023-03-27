#!/bin/bash

# install postgresql client
echo 'installing psql...'
apk --update add postgresql-client gettext

# create OMOP CDM schema and user
export pg_cdm_password="${PG_CDM_PASSWORD}${PG_CDM_USERNAME}"
export cdm_md5="'md5$(echo -n $pg_cdm_password | md5sum | awk '{ print $1 }')'"

printf 'Creating omp cdm schemas and user\n'
create_omop_cdm_script=$(envsubst < create_omop_cdm.sql)
echo "$create_omop_cdm_script" | psql "$OMOP_CONNECTION_STRING"

# create OMOP CDM tables
printf 'Creating OMOP CDM tables\n'
sed -i  s/@cdmDatabaseSchema/${OMOP_CDM_SCHEMA_NAME}/g OMOPCDM_postgresql_5.4_ddl.sql OMOPCDM_postgresql_5.4_constraints.sql OMOPCDM_postgresql_5.4_primary_keys.sql OMOPCDM_postgresql_5.4_indices.sql
psql "$OMOP_CONNECTION_STRING" -f OMOPCDM_postgresql_5.4_ddl.sql

#TODO create and load OMOP Vocabulary & Results tables

# skip foreign key constraints for now due to open bug - https://github.com/OHDSI/CommonDataModel/issues/452
#psql "$OMOP_CONNECTION_STRING" -f OMOPCDM_postgresql_5.4_constraints.sql

# create OMOP CDM primary keys
printf 'Creating OMOP CDM primary keys\n'
psql "$OMOP_CONNECTION_STRING" -f OMOPCDM_postgresql_5.4_primary_keys.sql

# load OMOP CDM data
#tables=("cdm.concept_ancestor" "cdm.concept_relationship" "cdm.source_to_source_vocab_map" "cdm.source_to_standard_vocab_map" "cdm.concept" "cdm.drug_strength" "cdm.concept_synonym" "cdm.measurement" "cdm.observation" "cdm.cost" "cdm.assign_all_visit_ids" "cdm.visit_detail" "cdm.visit_occurrence" "cdm.all_visits" "cdm.payer_plan_period" "cdm.drug_exposure" "cdm.procedure_occurrence" "cdm.final_visit_ids" "cdm.condition_occurrence" "cdm.condition_era" "cdm.provider" "cdm.drug_era" "cdm.person" "cdm.relationship" "cdm.observation_period" "cdm.concept_class" "cdm.device_exposure" "cdm.death" "cdm.cdm_source" "cdm.vocabulary" "cdm.domain")
#load subset of tables for now to speed up testing
printf 'Loading OMOP CDM data\n'
tables=("cdm.all_visits" "cdm.person" "cdm.drug_era" "cdm.death")
n=${#tables[@]}
i=0
for element in "${tables[@]}"; do
    ((i++));
    printf "Downloading and extracting: %s (%s)\n" "$element.csv.gz" "$i/$n"
    curl "${CDM_CONTAINER_URL}$element.csv.gz${CDM_SAS_TOKEN}" | gunzip > $element.csv
    num_of_records=$(wc -l $element.csv | awk '{print $1}')
    printf "Copying %s to table: %s\n" "$num_of_records" "$element"
    psql "$OMOP_CONNECTION_STRING" -c "\COPY $element FROM '$element.csv' WITH CSV;"
    printf "done"
done

# create OMOP CDM indices
printf 'creating OMOP CDM indices\n'
#psql "$OMOP_CONNECTION_STRING" -f OMOPCDM_postgresql_5.4_indices.sql;

# add OMOP CDM source to WebAPI
printf 'adding OMOP CDM source to WebAPI\n'
add_omop_source_script=$(envsubst < add_omop_source.sql)
echo "$add_omop_source_script" | psql "$ATLAS_DB_CONNECTION_STRING"
