#!bin/bash

apk --update add postgresql-client gettext
admin_user_password="${OHDSI_ADMIN_PASSWORD}${OHDSI_ADMIN_USERNAME}"
app_user_password="${OHDSI_APP_PASSWORD}${OHDSI_APP_USERNAME}"
export admin_md5="'md5$(echo -n $admin_user_password | md5sum | awk '{ print $1 }')'"
export app_md5="'md5$(echo -n $app_user_password | md5sum | awk '{ print $1 }')'"

atlas_create_roles_users_script=$(envsubst < atlas_create_roles_users.sql)
atlas_create_schema_script=$(envsubst < atlas_create_schema.sql)

printf 'Creating roles and users'
echo "$atlas_create_roles_users_script" | psql -e "$MAIN_CONNECTION_STRING"

printf 'Creating schema'
echo "$atlas_create_schema_script" | psql -e "$OHDSI_ADMIN_CONNECTION_STRING"

printf 'Done'
