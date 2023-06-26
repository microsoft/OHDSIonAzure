-- This gives existing non-admin users access to all sources plus 'Atlas User' role.
-- It runs once after the deployment so new users created manually should also be given right permissions.

INSERT INTO webapi.sec_user_role (role_id, user_id)
SELECT r.id as role_id, u.id as user_id
FROM webapi.sec_user u cross join webapi.sec_role r
WHERE u.name <> 'admin' AND r.name LIKE 'Source user%'
EXCEPT
SELECT role_id, user_id
FROM webapi.sec_user_role;
