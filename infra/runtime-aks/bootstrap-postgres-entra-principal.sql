SELECT *
FROM pgaadauth_create_principal(:'app_principal_name', false, false)
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_roles
  WHERE rolname = :'app_principal_name'
);

GRANT CONNECT ON DATABASE :"database_name" TO :"app_principal_name";

GRANT USAGE ON SCHEMA public TO :"app_principal_name";

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public
TO :"app_principal_name";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES
TO :"app_principal_name";