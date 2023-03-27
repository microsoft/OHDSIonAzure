CREATE ROLE ${OMOP_CDM_ROLE} VALID UNTIL 'infinity'; 
COMMENT ON ROLE ${OMOP_CDM_ROLE} IS 'Application group for OHDSI OMOP CDM'; 
CREATE ROLE ${PG_CDM_USERNAME} LOGIN ENCRYPTED PASSWORD ${APP_MD5} VALID UNTIL 'infinity'; 
GRANT ${OMOP_CDM_ROLE} TO ${PG_CDM_USERNAME}; 
COMMENT ON ROLE ${PG_CDM_USERNAME} IS 'Application user account for OHDSI OMOP CDM'; 
GRANT CONNECT, TEMPORARY ON DATABASE ${DATABASE_NAME} TO GROUP ${OMOP_CDM_ROLE};

CREATE SCHEMA ${OMOP_CDM_SCHEMA_NAME} AUTHORIZATION ${OMOP_CDM_ROLE}; 
COMMENT ON SCHEMA ${OMOP_CDM_SCHEMA_NAME} IS 'Schema containing tables of the OMOP CDM'; 
GRANT USAGE ON SCHEMA ${OMOP_CDM_SCHEMA_NAME} TO PUBLIC; 
GRANT USAGE ON SCHEMA ${OMOP_CDM_SCHEMA_NAME} TO GROUP ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_CDM_SCHEMA_NAME} GRANT SELECT ON TABLES TO ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_CDM_SCHEMA_NAME} GRANT SELECT, USAGE ON SEQUENCES TO ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_CDM_SCHEMA_NAME} GRANT EXECUTE ON FUNCTIONS TO ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_CDM_SCHEMA_NAME} GRANT USAGE ON TYPES TO ${OMOP_CDM_ROLE};

CREATE SCHEMA ${OMOP_VOCABULARY_SCHEMA_NAME} AUTHORIZATION ${OMOP_CDM_ROLE}; 
COMMENT ON SCHEMA ${OMOP_VOCABULARY_SCHEMA_NAME} IS 'Schema containing tables of the OMOP Vocabulary'; 
GRANT USAGE ON SCHEMA ${OMOP_VOCABULARY_SCHEMA_NAME} TO PUBLIC; 
GRANT USAGE ON SCHEMA ${OMOP_VOCABULARY_SCHEMA_NAME} TO GROUP ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_VOCABULARY_SCHEMA_NAME} GRANT SELECT ON TABLES TO ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_VOCABULARY_SCHEMA_NAME} GRANT SELECT, USAGE ON SEQUENCES TO ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_VOCABULARY_SCHEMA_NAME} GRANT EXECUTE ON FUNCTIONS TO ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_VOCABULARY_SCHEMA_NAME} GRANT USAGE ON TYPES TO ${OMOP_CDM_ROLE};

CREATE SCHEMA ${OMOP_RESULTS_SCHEMA_NAME} AUTHORIZATION ${OMOP_CDM_ROLE}; 
COMMENT ON SCHEMA ${OMOP_RESULTS_SCHEMA_NAME} IS 'Schema containing tables of the OMOP Results'; 
GRANT USAGE ON SCHEMA ${OMOP_RESULTS_SCHEMA_NAME} TO PUBLIC; 
GRANT USAGE ON SCHEMA ${OMOP_RESULTS_SCHEMA_NAME} TO GROUP ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_RESULTS_SCHEMA_NAME} GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLES TO ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_RESULTS_SCHEMA_NAME} GRANT SELECT, USAGE ON SEQUENCES TO ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_RESULTS_SCHEMA_NAME} GRANT EXECUTE ON FUNCTIONS TO ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_RESULTS_SCHEMA_NAME} GRANT USAGE ON TYPES TO ${OMOP_CDM_ROLE};

CREATE SCHEMA ${OMOP_TEMP_SCHEMA_NAME} AUTHORIZATION ${OMOP_CDM_ROLE}; 
COMMENT ON SCHEMA ${OMOP_TEMP_SCHEMA_NAME} IS 'Schema containing tables of the OMOP Temporary'; 
GRANT USAGE ON SCHEMA ${OMOP_TEMP_SCHEMA_NAME} TO PUBLIC; 
GRANT ALL ON SCHEMA ${OMOP_TEMP_SCHEMA_NAME} TO GROUP ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_TEMP_SCHEMA_NAME} GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLES TO ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_TEMP_SCHEMA_NAME} GRANT SELECT, USAGE ON SEQUENCES TO ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_TEMP_SCHEMA_NAME} GRANT EXECUTE ON FUNCTIONS TO ${OMOP_CDM_ROLE}; 
ALTER DEFAULT PRIVILEGES IN SCHEMA ${OMOP_TEMP_SCHEMA_NAME} GRANT USAGE ON TYPES TO ${OMOP_CDM_ROLE};