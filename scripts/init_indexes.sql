/*
===============================================================================
DDL Script: Create Indexes (PostgreSQL)
===============================================================================
Script Purpose:
    Creates indexes on the Silver layer tables to improve performance of
    Data Warehouse load (Gold layer generation) and reporting queries.
    Focuses on Primary Keys and Foreign Keys used in Joins.
===============================================================================
*/

-- Silver CRM Customer Info
CREATE INDEX IF NOT EXISTS idx_silver_crm_cust_info_cst_id 
    ON silver.crm_cust_info (cst_id);

-- Silver CRM Product Info
CREATE INDEX IF NOT EXISTS idx_silver_crm_prd_info_prd_id 
    ON silver.crm_prd_info (prd_id);

CREATE INDEX IF NOT EXISTS idx_silver_crm_prd_info_cat_id 
    ON silver.crm_prd_info (cat_id);

-- Silver CRM Sales Details
CREATE INDEX IF NOT EXISTS idx_silver_crm_sales_details_sls_ord_num 
    ON silver.crm_sales_details (sls_ord_num);

CREATE INDEX IF NOT EXISTS idx_silver_crm_sales_details_sls_prd_key 
    ON silver.crm_sales_details (sls_prd_key);

CREATE INDEX IF NOT EXISTS idx_silver_crm_sales_details_sls_cust_id 
    ON silver.crm_sales_details (sls_cust_id);

-- Silver ERP Tables (Dimension lookups)
CREATE INDEX IF NOT EXISTS idx_silver_erp_cust_az12_cid 
    ON silver.erp_cust_az12 (cid);

CREATE INDEX IF NOT EXISTS idx_silver_erp_loc_a101_cid 
    ON silver.erp_loc_a101 (cid);

CREATE INDEX IF NOT EXISTS idx_silver_erp_px_cat_g1v2_id 
    ON silver.erp_px_cat_g1v2 (id);
