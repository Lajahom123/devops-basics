SELECT *
FROM pg_catalog.pgaadauth_create_principal(:'principal_name', false, false)
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_roles
  WHERE rolname = :'principal_name'
);