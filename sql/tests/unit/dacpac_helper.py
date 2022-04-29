import os
from subprocess import Popen, PIPE
import sys
import logging
from enum import Enum


log = logging.getLogger(__name__)


class DacpacHelperError(RuntimeError):
    """
    This is a wrapper for the DacpacHelper when it has an issue with running.
    """


class DacpacHelperEnvironmentVariables(str, Enum):
    """
    Enumerates environment variables used for the Dacpac Helper
    """

    #: Environment Variable for SQL Package Connection String for testing
    SQL_PACKAGE_CONNECTION_STRING = "SQL_PACKAGE_CONNECTION_STRING"

    #: Environment Variable for sqlpackage path
    SQLPACKAGE_PATH = "SQLPACKAGE_PATH"

    #: Environment Variable for the vocabulary ddl Dacpac Path
    DOTNET_VOCABULARY_DDL_DACPAC_PATH = "DOTNET_VOCABULARY_DDL_DACPAC_PATH"

    #: Environment Variable for the vocabulary indexes constraints Dacpac Path
    DOTNET_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC_PATH = "DOTNET_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC_PATH"

    #: Environment Variable for the empty dacpac path
    DOTNET_EMPTY_DACPAC_PATH = "DOTNET_EMPTY_DACPAC_PATH"

    def __str__(self):
        return str(self.value)


class DacpacHelper(object):
    """
    DacpacHelper which will let you use a dacpac against a sql database using sqlpackage
    """

    @classmethod
    def _run_process(cls, cmd):
        p = Popen(cmd, stdout=PIPE, stderr=PIPE, shell=True)
        print(f"Executing subprocess with {cmd}")
        stdout, stderr = p.communicate()
        sys.stdout.write(stdout.decode("utf-8"))
        sys.stderr.write(stderr.decode("utf-8"))
        log.info(stdout)
        log.error(stderr)

        if p.returncode != 0:
            raise DacpacHelperError(
                f"""
            Could not execute subprocess with: {cmd}
            stdout: {stdout}
            stderr: {stderr}
            """
            )

    @classmethod
    def run_vocabulary_ddl_dacpac(cls):
        """
        Run Vocabulary DDL dacpac

        This relies on the environment variables:
        `SQL_PACKAGE_CONNECTION_STRING` : This is the connection string for SQL Server
        `DOTNET_VOCABULARY_DDL_DACPAC_PATH` : This is the path for the dotnet_vocabulary_ddl dacpac
        `SQLPACKAGE_PATH` : This is the sqlpackage path
        """
        conn_str = os.environ[DacpacHelperEnvironmentVariables.SQL_PACKAGE_CONNECTION_STRING]
        dacpac_file = os.environ[DacpacHelperEnvironmentVariables.DOTNET_VOCABULARY_DDL_DACPAC_PATH]
        sqlpackage_path = os.environ[DacpacHelperEnvironmentVariables.SQLPACKAGE_PATH]
        # run the dacpac
        cmd = f'{sqlpackage_path} /a:publish /sf:"{dacpac_file}" /tcs:"{conn_str}"'
        cls._run_process(cmd)

    @classmethod
    def run_vocabulary_indexes_constraints_dacpac(cls):
        """
        Run Vocabulary Indexes Constraints dacpac

        This relies on the environment variables:
        `SQL_PACKAGE_CONNECTION_STRING` : This is the connection string for SQL Server
        `DOTNET_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC_PATH` : This is the path for the dotnet_vocabualry_indexes_constraints dacpac
        `SQLPACKAGE_PATH` : This is the sqlpackage path
        """
        conn_str = os.environ[DacpacHelperEnvironmentVariables.SQL_PACKAGE_CONNECTION_STRING]
        dacpac_file = os.environ[DacpacHelperEnvironmentVariables.DOTNET_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC_PATH]
        sqlpackage_path = os.environ[DacpacHelperEnvironmentVariables.SQLPACKAGE_PATH]
        # run the dacpac
        cmd = f'{sqlpackage_path} /a:publish /sf:"{dacpac_file}" /tcs:"{conn_str}"'
        cls._run_process(cmd)

    @classmethod
    def run_empty_dacpac(cls, conn_str):
        """
        Run empty dacpac to clear objects

        `conn_str` : This is the connection string for SQL Server

        This relies on the environment variables:
        `DOTNET_EMPTY_DACPAC_PATH` : This is the path for the empty dacpac
        `SQLPACKAGE_PATH` : This is the sqlpackage path
        """
        dacpac_file = os.environ[DacpacHelperEnvironmentVariables.DOTNET_EMPTY_DACPAC_PATH]
        sqlpackage_path = os.environ[DacpacHelperEnvironmentVariables.SQLPACKAGE_PATH]
        # run the dacpac
        cmd = (
            f'{sqlpackage_path} /a:publish /sf:"{dacpac_file}" /tcs:"{conn_str}" '
            "/p:DropObjectsNotInSource=true /p:BlockOnPossibleDataLoss=false"
        )
        cls._run_process(cmd)
