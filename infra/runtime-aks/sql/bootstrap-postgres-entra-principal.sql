SELECT *
FROM pgaadauth_create_principal(:'app_principal_name', false, false)
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_roles
  WHERE rolname = :'app_principal_name'
);