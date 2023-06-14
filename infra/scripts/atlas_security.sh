#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

LOG_FILE=/mnt/azscripts/azscriptoutput/all.log
exec >  >(tee -ia ${LOG_FILE})
exec 2> >(tee -ia ${LOG_FILE} >&2)

apk --update add postgresql-client apache2-utils

psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "$SQL_ATLAS_CREATE_SECURITY"

count=1
for i in ${ATLAS_USERS//,/ }
do
    if [ "$(("$count" % 2))" -eq "1" ]; then
        username=$i
    else
        # shellcheck disable=SC2016
        atlaspw=$(htpasswd -bnBC 4 "" "$i" | tr -d ':\n' | sed 's/$2y/$2a/')
        psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi_security.security (email,password) values ('$username', E'$atlaspw');"
        # this step adds some required rows/ids in the db
        curl "$WEBAPI_URL/user/login/db" --data-urlencode "login=$username" --data-urlencode "password=$i" --fail

        if [ "$count" = "2" ]; then
            psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi.sec_user_role (user_id, role_id) values ((select id from webapi.sec_user where login='$username'),2);" #admin role
        else
            psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi.sec_user_role (user_id, role_id) values ((select id from webapi.sec_user where login='$username'),10);" #atlas user role
        fi
    fi
    ((count++))
done
