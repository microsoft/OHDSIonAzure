import pandas as pd

from hamcrest import assert_that, is_, equal_to

from sqlalchemy import MetaData
from sqlalchemy.ext.declarative import declarative_base
import pytest


@pytest.mark.usefixtures("db_config")
class TestDboUnitTest(object):
    """
    'Unit' test cases verifying the existence of DBO schema and results
    """

    # Class set up / tear down
    @classmethod
    def setup_class(cls):
        """
        Called before any of the other methods in this class.
        """
        # Dacpac calls handled through fixture

    @classmethod
    def teardown_class(cls):
        """
        Called after all of the other methods in this class.
        """
        # clean out test db handled through fixture

    # Instance set up / tear down
    def setup(self):
        """
        Called before each method in this class with a name of the form test_*().
        """
        self.connection = self._engine.connect()

    def teardown(self):
        """
        Called after each method in this class with a name of the form test_*().
        """
        self.connection.close()

    # Test cases
    def test_is_test_database_name_correct(self):
        """
        Test case ensuring that the test database has the name we expect, i.e. something that
        couldn't ever be a 'real' environment database.
        """
        result = self.connection.execute("SELECT DB_NAME()")
        first_row_result = next(result)[0]
        assert_that(
            first_row_result,
            is_(self.expected_db_name),
            f"Got actual db_name {first_row_result} but expected {self.expected_db_name}",
        )

    def test_is_test_database_accessible(self):
        """
        Test case ensuring that the test database is accessible.
        """
        result = self.connection.execute("SELECT 1")
        first_row_result = next(result)[0]
        assert_that(first_row_result, is_(1), "Unable to connect to test database")

    def test_table_names_match(self, db_config):
        """
        Test table names match expected ones
        """
        Base = declarative_base()
        metadata = MetaData(bind=self._engine)
        Base.metadata = metadata
        metadata.reflect()

        actual_tables = set(metadata.tables.keys())
        expected_tables = set(db_config.expected_table_row_count.keys())
        assert (
            actual_tables == expected_tables
        ), f"Unexpected tables included! Found {actual_tables} but expected {expected_tables}"

    def test_table_row_counts(self, db_config):
        """
        Test the tables have expected row counts
        """
        # check tables
        for table_name in db_config.expected_table_row_count.keys():
            result = self.connection.execute(f"SELECT COUNT(*) FROM [dbo].[{table_name}]")
            first_row_result = next(result)[0]
            # the table should have the expected row count
            assert_that(
                first_row_result,
                is_(db_config.expected_table_row_count[table_name]),
                f"Getting count from table {table_name} expected {db_config.expected_table_row_count[table_name]} but got count {first_row_result}",
            )

    def test_expected_indexes_results(self, db_config, vocabulary_expected_indexes_query):
        """
        Test for expected indexes
        """
        query = vocabulary_expected_indexes_query

        actual = pd.read_sql_query(query, self.connection)
        expected = db_config.vocabulary_expected_indexes  # should be pandas dataframe

        # find the diff between the data frames
        diff_df = pd.merge(actual, expected, how="outer", on=["index_name", "index_type"], indicator="Exist")
        diff_df = diff_df.loc[diff_df["Exist"] != "both"]

        assert_that(
            diff_df.empty,
            equal_to(True),
            f"""unexpected result,
                got actual: {actual}
                but expecting: {expected}
                and diff: {diff_df}
                """,
        )

    def test_expected_constraints_results(self, db_config, vocabulary_expected_constraints_query):
        """
        Test for expected constraints
        """
        query = vocabulary_expected_constraints_query

        actual = pd.read_sql_query(query, self.connection)
        expected = db_config.vocabulary_expected_constraints  # should be pandas dataframe

        diff_df = pd.merge(actual, expected, how="outer", on=["CONSTRAINT_NAME", "CONSTRAINT_TYPE"], indicator="Exist")
        diff_df = diff_df.loc[diff_df["Exist"] != "both"]

        assert_that(
            diff_df.empty,
            equal_to(True),
            f"""unexpected result,
                got actual: {actual}
                but expecting: {expected}
                and diff: {diff_df}
                """,
        )
