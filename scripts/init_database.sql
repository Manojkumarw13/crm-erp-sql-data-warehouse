/*
=============================================================
Create Database and Schemas (PostgreSQL)
=============================================================
Script Purpose:
    This script creates a new database named "DataWarehouse" in PostgreSQL.
    If the database exists, it is dropped and recreated. The script also
    creates three schemas within the database: "bronze", "silver", and "gold".

WARNING:
    Running this script will permanently delete the entire "DataWarehouse"
    database if it exists. Ensure you have backups before running this script.

USAGE:
    This file uses psql meta-commands (\c) to change the connection.
    Run with the psql client as a superuser (or a role allowed to
    terminate other backends and to create/drop databases):

      psql -f scripts/init_database.sql

*/

-- Connect to a maintenance database first (psql meta-command)
\c postgres

-- Terminate other connections to the target database so it can be dropped.
-- Requires superuser privileges.
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'DataWarehouse'
  AND pid <> pg_backend_pid();

-- Drop the database if it exists, then recreate it
DROP DATABASE IF EXISTS "DataWarehouse";

CREATE DATABASE "DataWarehouse";

-- Connect to the newly created database (psql meta-command)
\c "DataWarehouse"

-- Create schemas if they don't already exist
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

-- End of script
