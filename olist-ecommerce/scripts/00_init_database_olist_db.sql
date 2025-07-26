

/*
============================================================
Create Schemas in PostgreSQL
============================================================
Script Purpose:
    - The database `olist_db` was manually created in PostgreSQL via DBeaver.
    - This script will create three logical schemas within that database:
        1. bronze
        2. silver
        3. gold

Notes:
    - Schemas help organize objects (tables, views, etc.) into layers.
    - `IF NOT EXISTS` is used to avoid errors if the schema already exists.
============================================================
*/

-- Switch to the target database before running (if needed)

-- Create schemas
CREATE SCHEMA IF NOT EXISTS bronze;

CREATE SCHEMA IF NOT EXISTS silver;

CREATE SCHEMA IF NOT EXISTS gold;

