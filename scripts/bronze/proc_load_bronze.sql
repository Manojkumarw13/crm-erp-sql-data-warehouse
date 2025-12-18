/*
===============================================================================
Query Tool Script: Load Bronze Layer (server-side COPY)
===============================================================================
Script Purpose:
    Loads CSV files into tables in the `bronze` schema using server-side
    `COPY` statements so the script can be run from GUI query tools (pgAdmin,
    DBeaver, etc.) that do not support psql meta-commands.

Requirements & Notes:
    - `COPY ... FROM <file>` reads files from the PostgreSQL server host.
      The server process must have access to these paths and the role running
      the script usually needs superuser privileges to read server files.
    - File paths in this project are Windows absolute paths. Ensure the server
      can access the same locations (or update the paths to server-local
      locations).
    - This script uses a single PL/pgSQL `DO` block to provide logging
      (`RAISE NOTICE`) and per-table timing. It will stop on errors.
===============================================================================
*/

CREATE OR REPLACE PROCEDURE load_bronze_layer()
LANGUAGE plpgsql
AS $$
DECLARE
    batch_start timestamptz := clock_timestamp();
    t_start timestamptz;
    t_end timestamptz;
    dur double precision;
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================================';

    -- CRM Tables
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    t_start := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    EXECUTE 'TRUNCATE TABLE bronze.crm_cust_info';
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
    EXECUTE format('COPY %I.%I FROM %L WITH (FORMAT csv, HEADER true)', 'bronze','crm_cust_info', 'C:\\sql\\dwh_project\\datasets\\source_crm\\cust_info.csv');
    t_end := clock_timestamp();
    dur := EXTRACT(EPOCH FROM t_end - t_start);
    RAISE NOTICE '>> Load Duration: % seconds', round(dur::numeric,3);

    t_start := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    EXECUTE 'TRUNCATE TABLE bronze.crm_prd_info';
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
    EXECUTE format('COPY %I.%I FROM %L WITH (FORMAT csv, HEADER true)', 'bronze','crm_prd_info', 'C:\\sql\\dwh_project\\datasets\\source_crm\\prd_info.csv');
    t_end := clock_timestamp();
    dur := EXTRACT(EPOCH FROM t_end - t_start);
    RAISE NOTICE '>> Load Duration: % seconds', round(dur::numeric,3);

    t_start := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    EXECUTE 'TRUNCATE TABLE bronze.crm_sales_details';
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
    EXECUTE format('COPY %I.%I FROM %L WITH (FORMAT csv, HEADER true)', 'bronze','crm_sales_details', 'C:\\sql\\dwh_project\\datasets\\source_crm\\sales_details.csv');
    t_end := clock_timestamp();
    dur := EXTRACT(EPOCH FROM t_end - t_start);
    RAISE NOTICE '>> Load Duration: % seconds', round(dur::numeric,3);

    -- ERP Tables
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';

    t_start := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
    EXECUTE 'TRUNCATE TABLE bronze.erp_loc_a101';
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
    EXECUTE format('COPY %I.%I FROM %L WITH (FORMAT csv, HEADER true)', 'bronze','erp_loc_a101', 'C:\\sql\\dwh_project\\datasets\\source_erp\\loc_a101.csv');
    t_end := clock_timestamp();
    dur := EXTRACT(EPOCH FROM t_end - t_start);
    RAISE NOTICE '>> Load Duration: % seconds', round(dur::numeric,3);

    t_start := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
    EXECUTE 'TRUNCATE TABLE bronze.erp_cust_az12';
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
    EXECUTE format('COPY %I.%I FROM %L WITH (FORMAT csv, HEADER true)', 'bronze','erp_cust_az12', 'C:\\sql\\dwh_project\\datasets\\source_erp\\cust_az12.csv');
    t_end := clock_timestamp();
    dur := EXTRACT(EPOCH FROM t_end - t_start);
    RAISE NOTICE '>> Load Duration: % seconds', round(dur::numeric,3);

    t_start := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
    EXECUTE 'TRUNCATE TABLE bronze.erp_px_cat_g1v2';
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
    EXECUTE format('COPY %I.%I FROM %L WITH (FORMAT csv, HEADER true)', 'bronze','erp_px_cat_g1v2', 'C:\\sql\\dwh_project\\datasets\\source_erp\\px_cat_g1v2.csv');
    t_end := clock_timestamp();
    dur := EXTRACT(EPOCH FROM t_end - t_start);
    RAISE NOTICE '>> Load Duration: % seconds', round(dur::numeric,3);

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Bronze Layer is Completed';
    RAISE NOTICE '   - Total Load Duration: % seconds', round(EXTRACT(EPOCH FROM clock_timestamp() - batch_start),3);
    RAISE NOTICE '==========================================';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'ERROR OCCURRED DURING LOADING BRONZE LAYER: %', SQLERRM;
    RAISE NOTICE '==========================================';
    RAISE; -- rethrow
END
$$ ;

-- To execute the procedure, run:
CALL bronze.load_bronze_layer();