INSERT INTO ${WEBAPI_SCHEMA_NAME}.source (source_id, source_name, source_key, source_connection, source_dialect) 
SELECT nextval('${WEBAPI_SCHEMA_NAME}.source_sequence'), '${OMOP_CDM_DATABASE_NAME}', '${OMOP_CDM_DATABASE_NAME}', '${OMOP_JDBC_CONNECTION_STRING}', 'postgresql';

INSERT INTO ${WEBAPI_SCHEMA_NAME}.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('${WEBAPI_SCHEMA_NAME}.source_daimon_sequence'), source_id, 0, '${POSTGRES_OMOP_CDM_SCHEMA_NAME}', 0
FROM ${WEBAPI_SCHEMA_NAME}.source
WHERE source_key = '${OMOP_CDM_DATABASE_NAME}';

-- Vocabulary tables are in the same schema as the CDM tables
INSERT INTO ${WEBAPI_SCHEMA_NAME}.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('${WEBAPI_SCHEMA_NAME}.source_daimon_sequence'), source_id, 1, '${POSTGRES_OMOP_CDM_SCHEMA_NAME}', 1
FROM ${WEBAPI_SCHEMA_NAME}.source
WHERE source_key = '${OMOP_CDM_DATABASE_NAME}';

INSERT INTO ${WEBAPI_SCHEMA_NAME}.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('${WEBAPI_SCHEMA_NAME}.source_daimon_sequence'), source_id, 2, '${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}', 1
FROM ${WEBAPI_SCHEMA_NAME}.source
WHERE source_key = '${OMOP_CDM_DATABASE_NAME}';

INSERT INTO ${WEBAPI_SCHEMA_NAME}.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('${WEBAPI_SCHEMA_NAME}.source_daimon_sequence'), source_id, 5, '${POSTGRES_OMOP_TEMP_SCHEMA_NAME}', 0
FROM ${WEBAPI_SCHEMA_NAME}.source
WHERE source_key = '${OMOP_CDM_DATABASE_NAME}';