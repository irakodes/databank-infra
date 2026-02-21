DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_read') THEN
    CREATE ROLE app_read;
  END IF;
END$$;