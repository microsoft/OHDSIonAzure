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
id=1000
for i in $(echo $ATLAS_USERS | sed "s/,/ /g")
do
if [ `expr $count % 2` -eq "1" ]; then
    username=$i
    let count+=1
    continue
else
    atlaspw=`htpasswd -bnBC 4 "" $i | tr -d ':\n' | sed 's/$2y/$2a/'`
    psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi_security.security (email,password) values ('$username', E'$atlaspw');"
    psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi.sec_user (id, login, name) values ($id, '$username', '$username') ON CONFLICT DO NOTHING;"
    psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi.sec_user_role (user_id, role_id) values ($id,1);" #public role
    if [ "$count" = "2" ]; then
    psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi.sec_user_role (user_id, role_id) values ($id,2);" #admin role
    else
    psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi.sec_user_role (user_id, role_id) values ($id,10);"  #atlas user role
    fi
    let count+=1
    let id+=1
fi
done
