#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

LOG_FILE=${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/all.log

exec >  >(tee -ia "${LOG_FILE}")
exec 2> >(tee -ia "${LOG_FILE}" >&2)

apk --update add postgresql-client gettext python3 py3-pip


# Embedded Python script to generate SCRAM-SHA-256 hashes
generate_scram_hash() {
    local password=$1
    python3 - <<END
from base64 import standard_b64encode
from hashlib import pbkdf2_hmac, sha256
from os import urandom
import hmac
import sys


salt_size = 16
digest_len = 32
iterations = 4096


def b64enc(b: bytes) -> str:
    return standard_b64encode(b).decode('utf8')


def pg_scram_sha256(passwd: str) -> str:
    salt = urandom(salt_size)
    digest_key = pbkdf2_hmac('sha256', passwd.encode('utf8'), salt, iterations,
                             digest_len)
    client_key = hmac.digest(digest_key, 'Client Key'.encode('utf8'), 'sha256')
    stored_key = sha256(client_key).digest()
    server_key = hmac.digest(digest_key, 'Server Key'.encode('utf8'), 'sha256')
    return (
        f'SCRAM-SHA-256\${iterations}:{b64enc(salt)}'
        f'\${b64enc(stored_key)}:{b64enc(server_key)}'
    )
if __name__ == "__main__":
    password = "$password"
    print(pg_scram_sha256(password))
END
}

admin_scram=$(generate_scram_hash "${OHDSI_ADMIN_PASSWORD}")
app_scram=$(generate_scram_hash "${OHDSI_APP_PASSWORD}")

export admin_scram="'${admin_scram}'"
export app_scram="'${app_scram}'"
echo "admin_scram: $admin_scram"
printf 'Creating roles and users'
echo "$SQL_ATLAS_USERS" | envsubst | psql -v ON_ERROR_STOP=0 -e "$MAIN_CONNECTION_STRING"
printf 'Creating roles and users: done.'

printf 'Creating schema'
echo "$SQL_ATLAS_SCHEMA" | envsubst | psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING"
printf 'Creating schema: done.'

printf 'Done'