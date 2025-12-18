/*
===============================================================================
Query Tool Script: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
	Performs ETL to populate the `silver` schema from `bronze` tables. This
	script is written as a PL/pgSQL `DO` block so it can be executed in GUI
	query tools (pgAdmin, DBeaver, etc.). It uses server-side SQL and
	`COPY` is not required here since data moves between schemas.

Notes:
	- This block uses `RAISE NOTICE` for logging and measures per-step
	  durations using `clock_timestamp()`.
	- Ensure the `bronze` and `silver` schemas/tables exist before running.
===============================================================================
*/

CREATE OR REPLACE PROCEDURE load_silver_layer()
LANGUAGE plpgsql
AS $$
DECLARE
	batch_start timestamptz := clock_timestamp();
	t_start timestamptz;
	t_end timestamptz;
	dur double precision;
BEGIN
	RAISE NOTICE '================================================';
	RAISE NOTICE 'Loading Silver Layer';
	RAISE NOTICE '================================================';

	RAISE NOTICE '------------------------------------------------';
	RAISE NOTICE 'Loading CRM Tables';
	RAISE NOTICE '------------------------------------------------';

	-- silver.crm_cust_info
	t_start := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
	EXECUTE 'TRUNCATE TABLE silver.crm_cust_info';
	RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';
	EXECUTE $sql$
		INSERT INTO silver.crm_cust_info (
			cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END AS cst_marital_status,
			CASE
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr,
			cst_create_date
		FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t
		WHERE flag_last = 1;
	$sql$;
	t_end := clock_timestamp();
	dur := EXTRACT(EPOCH FROM t_end - t_start);
	RAISE NOTICE '>> Load Duration: % seconds', round(dur::numeric,3);

	-- silver.crm_prd_info
	t_start := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';
	EXECUTE 'TRUNCATE TABLE silver.crm_prd_info';
	RAISE NOTICE '>> Inserting Data Into: silver.crm_prd_info';
	EXECUTE $sql$
		INSERT INTO silver.crm_prd_info (
			prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
		)
		SELECT
			prd_id,
			REPLACE(SUBSTR(prd_key,1,5), '-', '_') AS cat_id,
			SUBSTR(prd_key,7) AS prd_key,
			prd_nm,
			COALESCE(prd_cost, 0) AS prd_cost,
			CASE
				WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
				WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
				WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
				WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,
			prd_start_dt::date AS prd_start_dt,
			(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1) AS prd_end_dt
		FROM bronze.crm_prd_info;
	$sql$;
	t_end := clock_timestamp();
	dur := EXTRACT(EPOCH FROM t_end - t_start);
	RAISE NOTICE '>> Load Duration: % seconds', round(dur::numeric,3);

	-- silver.crm_sales_details
	t_start := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
	EXECUTE 'TRUNCATE TABLE silver.crm_sales_details';
	RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';
	EXECUTE $sql$
		INSERT INTO silver.crm_sales_details (
			sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
		)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN sls_order_dt IS NULL OR sls_order_dt = 0 OR length(sls_order_dt::text) != 8 THEN NULL
				ELSE to_date(sls_order_dt::text, 'YYYYMMDD')
			END AS sls_order_dt,
			CASE
				WHEN sls_ship_dt IS NULL OR sls_ship_dt = 0 OR length(sls_ship_dt::text) != 8 THEN NULL
				ELSE to_date(sls_ship_dt::text, 'YYYYMMDD')
			END AS sls_ship_dt,
			CASE
				WHEN sls_due_dt IS NULL OR sls_due_dt = 0 OR length(sls_due_dt::text) != 8 THEN NULL
				ELSE to_date(sls_due_dt::text, 'YYYYMMDD')
			END AS sls_due_dt,
			CASE
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * abs(sls_price) THEN sls_quantity * abs(sls_price)
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE
				WHEN sls_price IS NULL OR sls_price <= 0 THEN (sls_sales::numeric / NULLIF(sls_quantity,0))
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;
	$sql$;
	t_end := clock_timestamp();
	dur := EXTRACT(EPOCH FROM t_end - t_start);
	RAISE NOTICE '>> Load Duration: % seconds', round(dur::numeric,3);

	-- silver.erp_cust_az12
	t_start := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';
	EXECUTE 'TRUNCATE TABLE silver.erp_cust_az12';
	RAISE NOTICE '>> Inserting Data Into: silver.erp_cust_az12';
	EXECUTE $sql$
		INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
		SELECT
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTR(cid,4) ELSE cid END AS cid,
			CASE WHEN bdate > current_date THEN NULL ELSE bdate END AS bdate,
			CASE
				WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
				ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12;
	$sql$;
	t_end := clock_timestamp();
	dur := EXTRACT(EPOCH FROM t_end - t_start);
	RAISE NOTICE '>> Load Duration: % seconds', round(dur::numeric,3);

	RAISE NOTICE '------------------------------------------------';
	RAISE NOTICE 'Loading ERP Tables';
	RAISE NOTICE '------------------------------------------------';

	-- silver.erp_loc_a101
	t_start := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';
	EXECUTE 'TRUNCATE TABLE silver.erp_loc_a101';
	RAISE NOTICE '>> Inserting Data Into: silver.erp_loc_a101';
	EXECUTE $sql$
		INSERT INTO silver.erp_loc_a101 (cid, cntry)
		SELECT
			REPLACE(cid, '-', '') AS cid,
			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry
		FROM bronze.erp_loc_a101;
	$sql$;
	t_end := clock_timestamp();
	dur := EXTRACT(EPOCH FROM t_end - t_start);
	RAISE NOTICE '>> Load Duration: % seconds', round(dur::numeric,3);

	-- silver.erp_px_cat_g1v2
	t_start := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';
	EXECUTE 'TRUNCATE TABLE silver.erp_px_cat_g1v2';
	RAISE NOTICE '>> Inserting Data Into: silver.erp_px_cat_g1v2';
	EXECUTE $sql$
		INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
		SELECT id, cat, subcat, maintenance FROM bronze.erp_px_cat_g1v2;
	$sql$;
	t_end := clock_timestamp();
	dur := EXTRACT(EPOCH FROM t_end - t_start);
	RAISE NOTICE '>> Load Duration: % seconds', round(dur::numeric,3);

	RAISE NOTICE '==========================================';
	RAISE NOTICE 'Loading Silver Layer is Completed';
	RAISE NOTICE '   - Total Load Duration: % seconds', round(EXTRACT(EPOCH FROM clock_timestamp() - batch_start),3);
	RAISE NOTICE '==========================================';
EXCEPTION WHEN OTHERS THEN
	RAISE NOTICE '==========================================';
	RAISE NOTICE 'ERROR OCCURRED DURING LOADING SILVER LAYER: %', SQLERRM;
	RAISE NOTICE '==========================================';
	RAISE;
END
$$ ;

-- To execute the procedure, run:
CALL silver.load_silver_layer();
