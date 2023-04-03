create schema IF NOT EXISTS webapi_security;

DROP TABLE IF EXISTS webapi_security.security;

CREATE TABLE webapi_security.security
(
    email character varying(255),
    password character varying(255)
);

insert into webapi_security.security (email,password) values ('admin', '$2a$10$opEKwT32fEvoPfSbzE1Rx.p8QsCG0KryiA7VEguLP/V0M62aho6mC');
insert into webapi_security.security (email,password) values ('ohdsi', '$2a$04$Fg8TEiD2u/xnDzaUQFyiP.uoDu4Do/tsYkTUCWNV0zTCW3HgnbJjO');

GRANT USAGE ON SCHEMA webapi_security TO PUBLIC;
GRANT ALL ON SCHEMA webapi_security TO GROUP ohdsi_admin;



do $$

	declare tables_count integer := 0;
	declare roles_count integer := 0;

begin
	
	while tables_count <> 3 loop
		raise notice 'Waiting for application security tables to become ready...';
	 	PERFORM pg_sleep(10);
	  	tables_count := (
			SELECT 	COUNT(*) 
			FROM 	pg_tables
			WHERE 	schemaname = 'webapi'
					AND tablename  in ('sec_user', 'sec_role', 'sec_user_role')
		);
   	end loop;

	raise notice 'All tables are ready.';

	while roles_count <> 3 loop
		raise notice 'Waiting for application security roles to become ready...';
	 	PERFORM pg_sleep(10);
	  	roles_count := (
			SELECT 	COUNT(*) 
			FROM 	webapi.sec_role
			WHERE 	id in (1, 2, 10)
		);
   	end loop;
	
	raise notice 'All roles are ready.';
	
	insert into webapi.sec_user (id, login, name) values (1000, 'admin', 'admin') ON CONFLICT DO NOTHING;
	insert into webapi.sec_user_role (user_id, role_id) values (1000, 2); -- admin role
	insert into webapi.sec_user_role (user_id, role_id) values (1000, 1); -- public role

	insert into webapi.sec_user (id, login, name) values (1001, 'ohdsi', 'ohdsi') ON CONFLICT DO NOTHING;
	insert into webapi.sec_user_role (user_id, role_id) values (1001, 10); -- atlas user role
	insert into webapi.sec_user_role (user_id, role_id) values (1001, 1); -- public role

   	raise notice 'Done.';

end$$;
