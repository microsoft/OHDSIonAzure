from subprocess import Popen, PIPE
import sys
import logging


log = logging.getLogger(__name__)


class ProcessHelperError(RuntimeError):
    """
    This is a wrapper for the ProcessHelper when it has an issue with running.
    """


class ProcessHelper(object):
    """
    ProcessHelper will let you run a command
    """

    @classmethod
    def _get_error(cls, cmd, stdout, stderr):
        return ProcessHelperError(
            f"""
            Could not execute subprocess with: {cmd}
            stdout: {stdout}
            stderr: {stderr}
            """
        )

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
            raise cls._get_error(cmd=cmd, stdout=stdout, stderr=stderr)
