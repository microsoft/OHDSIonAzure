#!bin/bash

apk --update add postgresql-client
admin_user_password="${OHDSI_ADMIN_PASSWORD}${OHDSI_ADMIN_USERNAME}"
app_user_password="${OHDSI_APP_PASSWORD}${OHDSI_APP_USERNAME}"
admin_md5="'md5$(echo -n $admin_user_password | md5sum | awk '{ print $1 }')'"
app_md5="'md5$(echo -n $app_user_password | md5sum | awk '{ print $1 }')'"

psql "$MAIN_CONNECTION_STRING" -f 
psql "$OHDSI_ADMIN_CONNECTION_STRING" -f 

printf 'Done'
