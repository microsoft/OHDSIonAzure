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
for i in $(echo $ATLASUSERS | sed "s/,/ /g")
do
if [ `expr $count % 2` -eq "1" ]; then
    username=$i
    let count+=1
    continue
else
    atlaspw=`htpasswd -bnBC 4 "" $i | tr -d ':\n' | sed 's/$2y/$2a/'`
    psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi_security.security (email,password) values ('$username', E'$atlaspw');"
    psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi.sec_user (id, login, name) values ($id, '$username', '$username') ON CONFLICT DO NOTHING;"
    let count+=1
    let id+=1
fi
done

count=1
for i in $(echo $ATLASUSERS | sed "s/,/ /g")
do
if [ `expr $count % 2` -eq "1" ]; then
    username=$i
    let count+=1
    continue
else
    userid=`psql -t -v ON_ERROR_STOP=1 "$OHDSI_ADMIN_CONNECTION_STRING" -c "select id from webapi.sec_user where login = '$username';"`
    if [ "$count" = "2" ]; then
    psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi.sec_user_role (user_id, role_id) values ($userid,2);"
    psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi.sec_user_role (user_id, role_id) values ($userid,10);"
    firstuser=$username
    firstpassword="$i"
    else
    psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "insert into webapi.sec_user_role (user_id, role_id) values ($userid,10);"
    fi
    let count+=1
fi
done
