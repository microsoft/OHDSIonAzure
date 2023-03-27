INSERT INTO ${WEBAPI_SCHEMA_NAME}.source (source_id, source_name, source_key, source_connection, source_dialect) 
SELECT nextval('${WEBAPI_SCHEMA_NAME}.source_sequence'), '${CDM_DATABASE_NAME}', '${CDM_DATABASE_NAME}', ' jdbc:postgresql://server:5432/cdm?user={user}&password={password}', 'postgresql';

INSERT INTO ${WEBAPI_SCHEMA_NAME}.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('${WEBAPI_SCHEMA_NAME}.source_daimon_sequence'), source_id, 0, 'cdm', 0
FROM ${WEBAPI_SCHEMA_NAME}.source
WHERE source_key = '${CDM_DATABASE_NAME}';

INSERT INTO ${WEBAPI_SCHEMA_NAME}.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('${WEBAPI_SCHEMA_NAME}.source_daimon_sequence'), source_id, 1, 'vocabulary', 1
FROM ${WEBAPI_SCHEMA_NAME}.source
WHERE source_key = '${CDM_DATABASE_NAME}';

INSERT INTO ${WEBAPI_SCHEMA_NAME}.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('${WEBAPI_SCHEMA_NAME}.source_daimon_sequence'), source_id, 2, 'results', 1
FROM ${WEBAPI_SCHEMA_NAME}.source
WHERE source_key = '${CDM_DATABASE_NAME}';

INSERT INTO ${WEBAPI_SCHEMA_NAME}.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('${WEBAPI_SCHEMA_NAME}.source_daimon_sequence'), source_id, 5, 'temp', 0
FROM ${WEBAPI_SCHEMA_NAME}.source
WHERE source_key = '${CDM_DATABASE_NAME}';