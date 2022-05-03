import pytest
import os
import pandas as pd
from sqlalchemy import create_engine
from tests.unit.docker_helper import DockerHelper
from tests.unit.dacpac_helper import DacpacHelper
from tests.unit.dacpac_helper import DacpacHelperEnvironmentVariables
from collections import namedtuple

from enum import Enum


class HelperEnvironmentVariables(str, Enum):
    """
    Enumerates environment variables used for the test
    """

    #: Environment Variable for SQL Connection String for unit test db
    UNIT_TEST_DB_URL = "UNIT_TEST_DB_URL"


class TestScenario(str, Enum):
    """
    Enumerates test scenario used for the test db
    """

    #: Test vocabulary ddl dacpac
    TEST_VOCABULARY_DDL_DACPAC = "test_vocabulary_ddl_dacpac"

    #: Test vocabulary indexes constraints dacpac
    TEST_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC = "test_vocabulary_indexes_constraints_dacpac"

    # Test vocabulary ddl dacpac and vocabulary indexes constraints dacpac
    TEST_VOCABULARY_DDL_AND_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC = (
        "test_vocabulary_ddl_and_vocabulary_indexes_constraints_dacpac"
    )

    def __str__(self):
        return str(self.value)


@pytest.fixture(scope="class")
def vocabulary_data_folder():
    return "tests/data/vocabulary"


@pytest.fixture(scope="class")
def vocabulary_data_files():
    return [
        "CONCEPT_ANCESTOR.csv",
        "CONCEPT_CLASS.csv",
        "CONCEPT_RELATIONSHIP.csv",
        "CONCEPT_SYNONYM.csv",
        "CONCEPT.csv",
        "DOMAIN.csv",
        "DRUG_STRENGTH.csv",
        "RELATIONSHIP.csv",
        "source_to_concept_map.csv",
        "VOCABULARY.csv",
    ]


@pytest.fixture(scope="class")
def vocabulary_ddl_expected_table_row_count():
    return {
        "attribute_definition": 0,
        "care_site": 0,
        "cdm_source": 0,
        "cohort": 0,
        "cohort_attribute": 0,
        "cohort_definition": 0,
        "concept": 1280,
        "concept_ancestor": 100,
        "concept_class": 415,
        "concept_relationship": 100,
        "concept_synonym": 4,
        "condition_era": 0,
        "condition_occurrence": 0,
        "cost": 0,
        "death": 0,
        "device_exposure": 0,
        "domain": 48,
        "dose_era": 0,
        "drug_era": 0,
        "drug_exposure": 0,
        "drug_strength": 100,
        "fact_relationship": 0,
        "location": 0,
        "measurement": 0,
        "metadata": 0,
        "note": 0,
        "note_nlp": 0,
        "observation": 0,
        "observation_period": 0,
        "payer_plan_period": 0,
        "person": 0,
        "procedure_occurrence": 0,
        "provider": 0,
        "relationship": 622,
        "source_to_concept_map": 0,
        "specimen": 0,
        "visit_detail": 0,
        "visit_occurrence": 0,
        "vocabulary": 58,
    }


@pytest.fixture(scope="class")
def vocabulary_indexes_constraints_expected_table_row_count():
    return {
        "attribute_definition": 0,
        "care_site": 0,
        "cdm_source": 0,
        "cohort": 0,
        "cohort_attribute": 0,
        "cohort_definition": 0,
        "concept": 0,
        "concept_ancestor": 0,
        "concept_class": 0,
        "concept_relationship": 0,
        "concept_synonym": 0,
        "condition_era": 0,
        "condition_occurrence": 0,
        "cost": 0,
        "death": 0,
        "device_exposure": 0,
        "domain": 0,
        "dose_era": 0,
        "drug_era": 0,
        "drug_exposure": 0,
        "drug_strength": 0,
        "fact_relationship": 0,
        "location": 0,
        "measurement": 0,
        "metadata": 0,
        "note": 0,
        "note_nlp": 0,
        "observation": 0,
        "observation_period": 0,
        "payer_plan_period": 0,
        "person": 0,
        "procedure_occurrence": 0,
        "provider": 0,
        "relationship": 0,
        "source_to_concept_map": 0,
        "specimen": 0,
        "visit_detail": 0,
        "visit_occurrence": 0,
        "vocabulary": 0,
    }


@pytest.fixture(scope="class")
def vocabulary_expected_indexes_query():
    return """
        SELECT i.[name] AS index_name,
            CASE
                WHEN i.[type] = 1 THEN 'Clustered index'
                WHEN i.[type] = 2 THEN 'Nonclustered unique index'
            END AS index_type
        FROM sys.objects t
        INNER JOIN sys.indexes i ON t.object_id = i.object_id
        WHERE t.is_ms_shipped <> 1
            AND schema_name(t.schema_id) = 'dbo'
            AND index_id > 0
        ORDER BY schema_name(t.schema_id) + '.' + t.[name], i.index_id
    """


@pytest.fixture(scope="class")
def vocabulary_ddl_dacpac_expected_indexes():
    return pd.DataFrame(columns=["index_name", "index_type"])  # should be empty pandas dataframe


@pytest.fixture(scope="class")
def vocabulary_indexes_constraints_dacpac_expected_indexes():
    records = [
        {"index_name": "idx_attribute_definition_id", "index_type": "Clustered index"},
        {
            "index_name": "xpk_attribute_definition",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "xpk_care_site", "index_type": "Nonclustered unique index"},
        {"index_name": "xpk_cohort", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_cohort_c_definition_id",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_cohort_subject_id",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "xpk_cohort_attribute",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_ca_definition_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_ca_subject_id", "index_type": "Nonclustered unique index"},
        {"index_name": "idx_cohort_definition_id", "index_type": "Clustered index"},
        {
            "index_name": "xpk_cohort_definition",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_concept_concept_id", "index_type": "Clustered index"},
        {"index_name": "xpk_concept", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_concept_class_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_concept_code", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_concept_domain_id",
            "index_type": "Nonclustered unique index",
        },
        {
            # https://github.com/OHDSI/CommonDataModel/blob/v5.3.1/Sql%20Server/OMOP%20CDM%20sql%20server%20indexes.txt#L197
            "index_name": "idx_concept_vocabluary_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_concept_ancestor_id_1", "index_type": "Clustered index"},
        {
            "index_name": "xpk_concept_ancestor",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_concept_ancestor_id_2",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_concept_class_class_id", "index_type": "Clustered index"},
        {"index_name": "xpk_concept_class", "index_type": "Nonclustered unique index"},
        {
            "index_name": "xpk_concept_relationship",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_concept_relationship_id_1",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_concept_relationship_id_2",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_concept_relationship_id_3",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_concept_synonym_id", "index_type": "Clustered index"},
        {"index_name": "idx_condition_era_person_id", "index_type": "Clustered index"},
        {"index_name": "xpk_condition_era", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_condition_era_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_condition_person_id", "index_type": "Clustered index"},
        {
            "index_name": "xpk_condition_occurrence",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_condition_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_condition_visit_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "xpk_visit_cost", "index_type": "Nonclustered unique index"},
        {"index_name": "idx_death_person_id", "index_type": "Clustered index"},
        {"index_name": "xpk_death", "index_type": "Nonclustered unique index"},
        {"index_name": "idx_device_person_id", "index_type": "Clustered index"},
        {
            "index_name": "xpk_device_exposure",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_device_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_device_visit_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_domain_domain_id", "index_type": "Clustered index"},
        {"index_name": "xpk_domain", "index_type": "Nonclustered unique index"},
        {"index_name": "idx_dose_era_person_id", "index_type": "Clustered index"},
        {"index_name": "xpk_dose_era", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_dose_era_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_drug_era_person_id", "index_type": "Clustered index"},
        {"index_name": "xpk_drug_era", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_drug_era_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_drug_person_id", "index_type": "Clustered index"},
        {"index_name": "xpk_drug_exposure", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_drug_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_drug_visit_id", "index_type": "Nonclustered unique index"},
        {"index_name": "idx_drug_strength_id_1", "index_type": "Clustered index"},
        {"index_name": "xpk_drug_strength", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_drug_strength_id_2",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_fact_relationship_id_1",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_fact_relationship_id_2",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_fact_relationship_id_3",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "xpk_location", "index_type": "Nonclustered unique index"},
        {"index_name": "idx_measurement_person_id", "index_type": "Clustered index"},
        {"index_name": "xpk_measurement", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_measurement_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_measurement_visit_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_note_person_id", "index_type": "Clustered index"},
        {"index_name": "xpk_note", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_note_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_note_visit_id", "index_type": "Nonclustered unique index"},
        {"index_name": "idx_note_nlp_note_id", "index_type": "Clustered index"},
        {"index_name": "xpk_note_nlp", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_note_nlp_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_observation_person_id", "index_type": "Clustered index"},
        {"index_name": "xpk_observation", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_observation_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_observation_visit_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_observation_period_id", "index_type": "Clustered index"},
        {
            "index_name": "xpk_observation_period",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_period_person_id", "index_type": "Clustered index"},
        {
            "index_name": "xpk_payer_plan_period",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_person_id", "index_type": "Clustered index"},
        {"index_name": "xpk_person", "index_type": "Nonclustered unique index"},
        {"index_name": "idx_procedure_person_id", "index_type": "Clustered index"},
        {
            "index_name": "xpk_procedure_occurrence",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_procedure_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_procedure_visit_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "xpk_provider", "index_type": "Nonclustered unique index"},
        {"index_name": "idx_relationship_rel_id", "index_type": "Clustered index"},
        {"index_name": "xpk_relationship", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_source_to_concept_map_id_3",
            "index_type": "Clustered index",
        },
        {
            "index_name": "xpk_source_to_concept_map",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_source_to_concept_map_code",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_source_to_concept_map_id_1",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_source_to_concept_map_id_2",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_specimen_person_id", "index_type": "Clustered index"},
        {"index_name": "xpk_specimen", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_specimen_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_visit_detail_person_id", "index_type": "Clustered index"},
        {"index_name": "xpk_visit_detail", "index_type": "Nonclustered unique index"},
        {
            "index_name": "idx_visit_detail_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_visit_person_id", "index_type": "Clustered index"},
        {
            "index_name": "xpk_visit_occurrence",
            "index_type": "Nonclustered unique index",
        },
        {
            "index_name": "idx_visit_concept_id",
            "index_type": "Nonclustered unique index",
        },
        {"index_name": "idx_vocabulary_vocabulary_id", "index_type": "Clustered index"},
        {"index_name": "xpk_vocabulary", "index_type": "Nonclustered unique index"},
    ]

    # return pandas dataframe
    return pd.DataFrame.from_records(records)


@pytest.fixture(scope="class")
def vocabulary_expected_constraints_query():
    return """
        SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE CONSTRAINT_SCHEMA = 'dbo'
        ORDER BY CONSTRAINT_NAME
    """


@pytest.fixture(scope="class")
def vocabulary_ddl_dacpac_expected_constraints():
    return pd.DataFrame(columns=["CONSTRAINT_NAME", "CONSTRAINT_TYPE"])  # should be empty pandas dataframe


@pytest.fixture(scope="class")
def vocabulary_indexes_constraints_dacpac_expected_constraints():
    records = [
        {"CONSTRAINT_NAME": "fpd_v_detail_visit", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_attribute_type_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_ca_attribute_definition",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_ca_cohort_definition",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_ca_value", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_care_site_location", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_care_site_place", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_cohort_definition_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_concept_class", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_concept_class_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_concept_domain", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_concept_relationship_id",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_concept_synonym_language",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_concept_vocabulary", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_condition_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_condition_concept_s",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_condition_era_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_condition_era_person",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_condition_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_condition_provider", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_condition_status_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_condition_type_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_condition_visit", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_death_cause_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_death_cause_concept_s",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_death_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_death_type_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_device_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_device_concept_s", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_device_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_device_provider", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_device_type_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_device_visit", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_domain_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_dose_era_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_dose_era_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_dose_era_unit_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_drg_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_drug_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_drug_concept_s", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_drug_era_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_drug_era_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_drug_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_drug_provider", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_drug_route_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_drug_strength_concept_1",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_drug_strength_concept_2",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_drug_strength_unit_1",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_drug_strength_unit_2",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_drug_strength_unit_3",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_drug_type_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_drug_visit", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_fact_domain_1", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_fact_domain_2", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_fact_relationship", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_language_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_measurement_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_measurement_concept_s",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_measurement_operator",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_measurement_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_measurement_provider",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_measurement_type_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_measurement_unit", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_measurement_value", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_measurement_visit", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_note_class_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_note_encoding_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_note_nlp_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_note_nlp_note", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_note_nlp_section_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_note_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_note_provider", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_note_type_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_note_visit", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_observation_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_observation_concept_s",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_observation_period_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_observation_period_person",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_observation_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_observation_provider",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_observation_qualifier",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_observation_type_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_observation_unit", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_observation_value", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_observation_visit", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_payer_plan_period", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_person_care_site", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_person_ethnicity_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_person_ethnicity_concept_s",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_person_gender_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_person_gender_concept_s",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_person_location", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_person_provider", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_person_race_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_person_race_concept_s",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_procedure_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_procedure_concept_s",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_procedure_modifier", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_procedure_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_procedure_provider", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_procedure_type_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_procedure_visit", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_provider_care_site", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_provider_gender", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_provider_gender_s", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_provider_specialty", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_provider_specialty_s",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_relationship_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_relationship_reverse",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_source_concept_id", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_source_to_concept_map_c_1",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_source_to_concept_map_v_1",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_source_to_concept_map_v_2",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_specimen_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_specimen_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_specimen_site_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_specimen_status_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_specimen_type_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_specimen_unit_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {
            "CONSTRAINT_NAME": "fpk_v_detail_admitting_s",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_v_detail_care_site", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_v_detail_concept_s", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_v_detail_discharge", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_v_detail_parent", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_v_detail_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_v_detail_preceding", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_v_detail_provider", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_v_detail_type_concept",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_visit_admitting_s", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_visit_care_site", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_visit_concept_s", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "fpk_visit_cost_currency",
            "CONSTRAINT_TYPE": "FOREIGN KEY",
        },
        {"CONSTRAINT_NAME": "fpk_visit_cost_period", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_visit_discharge", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_visit_person", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_visit_preceding", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_visit_provider", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_visit_type_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {"CONSTRAINT_NAME": "fpk_vocabulary_concept", "CONSTRAINT_TYPE": "FOREIGN KEY"},
        {
            "CONSTRAINT_NAME": "xpk_attribute_definition",
            "CONSTRAINT_TYPE": "PRIMARY KEY",
        },
        {"CONSTRAINT_NAME": "xpk_care_site", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_cohort", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_cohort_attribute", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_cohort_definition", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_concept", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_concept_ancestor", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_concept_class", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {
            "CONSTRAINT_NAME": "xpk_concept_relationship",
            "CONSTRAINT_TYPE": "PRIMARY KEY",
        },
        {"CONSTRAINT_NAME": "xpk_condition_era", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {
            "CONSTRAINT_NAME": "xpk_condition_occurrence",
            "CONSTRAINT_TYPE": "PRIMARY KEY",
        },
        {"CONSTRAINT_NAME": "xpk_death", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_device_exposure", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_domain", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_dose_era", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_drug_era", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_drug_exposure", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_drug_strength", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_location", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_measurement", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_note", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_note_nlp", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_observation", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_observation_period", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_payer_plan_period", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_person", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {
            "CONSTRAINT_NAME": "xpk_procedure_occurrence",
            "CONSTRAINT_TYPE": "PRIMARY KEY",
        },
        {"CONSTRAINT_NAME": "xpk_provider", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_relationship", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {
            "CONSTRAINT_NAME": "xpk_source_to_concept_map",
            "CONSTRAINT_TYPE": "PRIMARY KEY",
        },
        {"CONSTRAINT_NAME": "xpk_specimen", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_visit_cost", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_visit_detail", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_visit_occurrence", "CONSTRAINT_TYPE": "PRIMARY KEY"},
        {"CONSTRAINT_NAME": "xpk_vocabulary", "CONSTRAINT_TYPE": "PRIMARY KEY"},
    ]

    # return pandas dataframe
    return pd.DataFrame.from_records(records)


@pytest.fixture(scope="class")
def vocabulary_ddl_dacpac_db_config(
    request,
    vocabulary_ddl_expected_table_row_count,
    vocabulary_ddl_dacpac_expected_indexes,
    vocabulary_ddl_dacpac_expected_constraints,
):
    url = os.environ[HelperEnvironmentVariables.UNIT_TEST_DB_URL]
    engine = create_engine(url)
    request.cls._engine = engine
    request.cls.expected_db_name = url.split("/")[-1]

    db_config = namedtuple(
        "db_config",
        [
            "expected_table_row_count",
            "vocabulary_expected_indexes",
            "vocabulary_expected_constraints",
        ],
    )
    instance_db_config = db_config(
        vocabulary_ddl_expected_table_row_count,  # data should be loaded as part of unit test script
        vocabulary_ddl_dacpac_expected_indexes,
        vocabulary_ddl_dacpac_expected_constraints,
    )

    yield instance_db_config

    engine.dispose()


@pytest.fixture(scope="class")
def vocabulary_indexes_constraints_db_config(
    request,
    vocabulary_indexes_constraints_expected_table_row_count,
    vocabulary_indexes_constraints_dacpac_expected_indexes,
    vocabulary_indexes_constraints_dacpac_expected_constraints,
):
    url = os.environ[HelperEnvironmentVariables.UNIT_TEST_DB_URL]
    engine = create_engine(url)
    request.cls._engine = engine
    request.cls.expected_db_name = url.split("/")[-1]

    db_config = namedtuple(
        "db_config",
        [
            "expected_table_row_count",
            "vocabulary_expected_indexes",
            "vocabulary_expected_constraints",
        ],
    )
    instance_db_config = db_config(
        vocabulary_indexes_constraints_expected_table_row_count,
        vocabulary_indexes_constraints_dacpac_expected_indexes,
        vocabulary_indexes_constraints_dacpac_expected_constraints,
    )

    yield instance_db_config

    engine.dispose()


@pytest.fixture(scope="class")
def vocabulary_ddl_and_vocabulary_indexes_constraints_db_config(
    request,
    vocabulary_ddl_expected_table_row_count,
    vocabulary_indexes_constraints_dacpac_expected_indexes,
    vocabulary_indexes_constraints_dacpac_expected_constraints,
):
    url = os.environ[HelperEnvironmentVariables.UNIT_TEST_DB_URL]
    engine = create_engine(url)
    request.cls._engine = engine
    request.cls.expected_db_name = url.split("/")[-1]

    db_config = namedtuple(
        "db_config",
        [
            "expected_table_row_count",
            "vocabulary_expected_indexes",
            "vocabulary_expected_constraints",
        ],
    )
    instance_db_config = db_config(
        vocabulary_ddl_expected_table_row_count,  # data should be loaded as part of unit test script
        vocabulary_indexes_constraints_dacpac_expected_indexes,
        vocabulary_indexes_constraints_dacpac_expected_constraints,
    )

    yield instance_db_config

    engine.dispose()


@pytest.fixture(
    scope="class",
    params=[
        str(TestScenario.TEST_VOCABULARY_DDL_DACPAC),
        str(TestScenario.TEST_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC),
        str(TestScenario.TEST_VOCABULARY_DDL_AND_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC),
    ],
)
def db_config(
    request,
    vocabulary_ddl_dacpac_db_config,
    vocabulary_indexes_constraints_db_config,
    vocabulary_ddl_and_vocabulary_indexes_constraints_db_config,
    vocabulary_data_files,
    vocabulary_data_folder,
):
    param = request.param

    # Copy in files in for test data loading purposes.
    for vocabulary_file in vocabulary_data_files:
        DockerHelper.run_docker_copy(f"{vocabulary_data_folder}/{vocabulary_file}", vocabulary_file)

    if param == TestScenario.TEST_VOCABULARY_DDL_DACPAC:
        # deploy dacpac
        DacpacHelper.run_vocabulary_ddl_dacpac()

        yield vocabulary_ddl_dacpac_db_config

        # Force clean after scenario completes
        DacpacHelper.run_empty_dacpac(os.environ[DacpacHelperEnvironmentVariables.SQL_PACKAGE_CONNECTION_STRING])
    elif param == TestScenario.TEST_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC:
        # deploy dacpac
        DacpacHelper.run_vocabulary_indexes_constraints_dacpac()

        yield vocabulary_indexes_constraints_db_config

        # Force clean after scenario completes
        DacpacHelper.run_empty_dacpac(os.environ[DacpacHelperEnvironmentVariables.SQL_PACKAGE_CONNECTION_STRING])
    else:
        # deploy dacpacs
        DacpacHelper.run_vocabulary_ddl_dacpac()
        DacpacHelper.run_vocabulary_indexes_constraints_dacpac()

        yield vocabulary_ddl_and_vocabulary_indexes_constraints_db_config

        # Force clean after scenario completes
        DacpacHelper.run_empty_dacpac(os.environ[DacpacHelperEnvironmentVariables.SQL_PACKAGE_CONNECTION_STRING])
