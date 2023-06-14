INSERT INTO ${WEBAPI_SCHEMA_NAME}.source (source_id, source_name, source_key, source_connection, source_dialect, is_cache_enabled) 
SELECT nextval('${WEBAPI_SCHEMA_NAME}.source_sequence'), '${OMOP_CDM_DATABASE_NAME}', '${OMOP_CDM_DATABASE_NAME}', '${OMOP_JDBC_CONNECTION_STRING}', 'postgresql', true;

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

-- todo: add source user role

-- Add permissions for the OMOP CDM source
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('cohortdefinition:*:generate:${OMOP_CDM_DATABASE_NAME}:get', 'Generate Cohort on Source with SourceKey = ${OMOP_CDM_DATABASE_NAME}');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('cohortdefinition:*:report:${OMOP_CDM_DATABASE_NAME}:get',	'Get Inclusion Rule Report for Source with SourceKey = ${OMOP_CDM_DATABASE_NAME}');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('source:${OMOP_CDM_DATABASE_NAME}:access','Access to Source with SourceKey = ${OMOP_CDM_DATABASE_NAME}');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:*:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:included-concepts:count:post', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:resolveConceptSetExpression:post', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:lookup:identifiers:post', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:lookup:identifiers:ancestors:post', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:lookup:mapped:post', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:compare:post', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:optimize:post', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('cdmresults:${OMOP_CDM_DATABASE_NAME}:*:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('cdmresults:${OMOP_CDM_DATABASE_NAME}:*:*:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('cdmresults:${OMOP_CDM_DATABASE_NAME}:conceptRecordCount:post', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('cohortresults:${OMOP_CDM_DATABASE_NAME}:*:*:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('cohortresults:${OMOP_CDM_DATABASE_NAME}:*:*:*:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:concept:*:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:concept:*:related:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('cohortdefinition:*:cancel:${OMOP_CDM_DATABASE_NAME}:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:search:post', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('ir:*:execute:${OMOP_CDM_DATABASE_NAME}:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('ir:*:execute:${OMOP_CDM_DATABASE_NAME}:delete', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('${OMOP_CDM_DATABASE_NAME}:person:*:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:lookup:sourcecodes:post', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('cohort-characterization:*:generation:${OMOP_CDM_DATABASE_NAME}:post', '');	
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('cohort-characterization:*:generation:${OMOP_CDM_DATABASE_NAME}:delete', '');	
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('pathway-analysis:*:generation:${OMOP_CDM_DATABASE_NAME}:post', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('pathway-analysis:*:generation:${OMOP_CDM_DATABASE_NAME}:delete', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('ir:*:report:${OMOP_CDM_DATABASE_NAME}:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('ir:*:info:${OMOP_CDM_DATABASE_NAME}:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:search:*:get', '');	
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('cohortresults:${OMOP_CDM_DATABASE_NAME}:*:healthcareutilization:*:*:get',	'Get cohort results baseline on period for Source with SourceKey = ${OMOP_CDM_DATABASE_NAME}');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('cohortresults:${OMOP_CDM_DATABASE_NAME}:*:healthcareutilization:*:*:*:get', 'Get cohort results baseline on occurrence for Source with SourceKey = ${OMOP_CDM_DATABASE_NAME}');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('ir:${OMOP_CDM_DATABASE_NAME}:info:*:delete', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:concept:*:ancestorAndDescendant:get', '');
INSERT INTO ${WEBAPI_SCHEMA_NAME}.sec_permission (value, description)
     VALUES ('vocabulary:${OMOP_CDM_DATABASE_NAME}:lookup:recommended:post', '');

-- todo: assign permissions to source role