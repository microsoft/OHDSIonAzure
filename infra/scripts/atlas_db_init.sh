#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

LOG_FILE=${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/all.log

exec >  >(tee -ia "${LOG_FILE}")
exec 2> >(tee -ia "${LOG_FILE}" >&2)

apk --update add postgresql-client gettext
admin_user_password="${OHDSI_ADMIN_PASSWORD}${OHDSI_ADMIN_USERNAME}"
app_user_password="${OHDSI_APP_PASSWORD}${OHDSI_APP_USERNAME}"
admin_md5=$(echo -n "$admin_user_password" | md5sum | awk '{ print $1 }')
export admin_md5="'md5$admin_md5'"

app_md5=$(echo -n "$app_user_password" | md5sum | awk '{ print $1 }')
export app_md5="'md5$app_md5'"

printf 'Creating roles and users'
echo "$SQL_ATLAS_USERS" | envsubst | psql -v ON_ERROR_STOP=0 -e "$MAIN_CONNECTION_STRING"
printf 'Creating roles and users: done.'

printf 'Creating schema'
echo "$SQL_ATLAS_SCHEMA" | envsubst | psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING"
printf 'Creating schema: done.'

printf 'Done'
