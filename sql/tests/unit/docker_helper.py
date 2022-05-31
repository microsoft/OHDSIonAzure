import os
import logging
from enum import Enum

from tests.unit.process_helper import ProcessHelper


log = logging.getLogger(__name__)


class DockerHelperError(RuntimeError):
    """
    This is a wrapper for the DockerHelper when it has an issue with running.
    """


class DockerHelperEnvironmentVariables(str, Enum):
    """
    Enumerates environment variables used for the Docker Helper
    """

    #: Environment Variable for SQL Container Name
    SQL_SERVER_NAME = "SQL_SERVER_NAME"

    def __str__(self):
        return str(self.value)


class DockerHelper(ProcessHelper):
    """
    DockerHelper which will let you copy data into the sql database container
    """

    @classmethod
    def _get_error(cls, cmd, stdout, stderr):
        return DockerHelperError(
            f"""
            Could not execute subprocess with: {cmd}
            stdout: {stdout}
            stderr: {stderr}
            """
        )

    @classmethod
    def run_docker_copy(cls, src_path, dest_path):
        """
        Run docker cp src_path container_name:dest_path

        Assumes that src_path is available locally
        and that dest_path is available in the container

        This relies on the environment variables:
        `SQL_SERVER_NAME` : This is the container name for sql server
        """
        container_name = os.environ[DockerHelperEnvironmentVariables.SQL_SERVER_NAME]
        # run the dacpac
        cmd = f'docker cp "{src_path}" {container_name}:"{dest_path}"'
        cls._run_process(cmd)
