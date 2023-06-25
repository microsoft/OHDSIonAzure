CREATE TABLE IF NOT EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_analysis
(
    analysis_id integer,
    analysis_name character varying(255) COLLATE pg_catalog."default",
    stratum_1_name character varying(255) COLLATE pg_catalog."default",
    stratum_2_name character varying(255) COLLATE pg_catalog."default",
    stratum_3_name character varying(255) COLLATE pg_catalog."default",
    stratum_4_name character varying(255) COLLATE pg_catalog."default",
    stratum_5_name character varying(255) COLLATE pg_catalog."default",
    is_default integer,
    category character varying(255) COLLATE pg_catalog."default"
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_analysis
    OWNER to ${POSTGRES_ADMIN_USERNAME};


CREATE TABLE IF NOT EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results
(
    analysis_id integer,
    stratum_1 character varying COLLATE pg_catalog."default",
    stratum_2 character varying COLLATE pg_catalog."default",
    stratum_3 character varying COLLATE pg_catalog."default",
    stratum_4 character varying COLLATE pg_catalog."default",
    stratum_5 character varying COLLATE pg_catalog."default",
    count_value bigint
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results
    OWNER to ${POSTGRES_ADMIN_USERNAME};
-- Index: idx_ar_aid

-- DROP INDEX IF EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.idx_ar_aid;

CREATE INDEX IF NOT EXISTS idx_ar_aid
    ON ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results USING btree
    (analysis_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_ar_aid_s1

-- DROP INDEX IF EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.idx_ar_aid_s1;

CREATE INDEX IF NOT EXISTS idx_ar_aid_s1
    ON ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results USING btree
    (analysis_id ASC NULLS LAST, stratum_1 COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_ar_aid_s1234

-- DROP INDEX IF EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.idx_ar_aid_s1234;

CREATE INDEX IF NOT EXISTS idx_ar_aid_s1234
    ON ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results USING btree
    (analysis_id ASC NULLS LAST, stratum_1 COLLATE pg_catalog."default" ASC NULLS LAST, stratum_2 COLLATE pg_catalog."default" ASC NULLS LAST, stratum_3 COLLATE pg_catalog."default" ASC NULLS LAST, stratum_4 COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_ar_s1

-- DROP INDEX IF EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.idx_ar_s1;

CREATE INDEX IF NOT EXISTS idx_ar_s1
    ON ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results USING btree
    (stratum_1 COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_ar_s2

-- DROP INDEX IF EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.idx_ar_s2;

CREATE INDEX IF NOT EXISTS idx_ar_s2
    ON ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results USING btree
    (stratum_2 COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results_dist

-- DROP TABLE IF EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results_dist;

CREATE TABLE IF NOT EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results_dist
(
    analysis_id integer,
    stratum_1 character varying COLLATE pg_catalog."default",
    stratum_2 character varying COLLATE pg_catalog."default",
    stratum_3 character varying COLLATE pg_catalog."default",
    stratum_4 character varying COLLATE pg_catalog."default",
    stratum_5 character varying COLLATE pg_catalog."default",
    count_value bigint,
    min_value numeric,
    max_value numeric,
    avg_value numeric,
    stdev_value numeric,
    median_value numeric,
    p10_value numeric,
    p25_value numeric,
    p75_value numeric,
    p90_value numeric
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results_dist
    OWNER to ${POSTGRES_ADMIN_USERNAME};
-- Index: idx_ard_aid

-- DROP INDEX IF EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.idx_ard_aid;

CREATE INDEX IF NOT EXISTS idx_ard_aid
    ON ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results_dist USING btree
    (analysis_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_ard_s1

-- DROP INDEX IF EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.idx_ard_s1;

CREATE INDEX IF NOT EXISTS idx_ard_s1
    ON ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results_dist USING btree
    (stratum_1 COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_ard_s2

-- DROP INDEX IF EXISTS ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.idx_ard_s2;

CREATE INDEX IF NOT EXISTS idx_ard_s2
    ON ${POSTGRES_OMOP_RESULTS_SCHEMA_NAME}.achilles_results_dist USING btree
    (stratum_2 COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;