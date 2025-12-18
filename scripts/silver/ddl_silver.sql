
/*
===============================================================================
DDL Script: Create Silver Tables (PostgreSQL)
===============================================================================
Script Purpose:
    This script creates tables in the `silver` schema, dropping existing tables
    if they already exist. It is formatted to run in PostgreSQL query tools
    (pgAdmin, DBeaver, etc.).

Notes:
    - Uses `DROP TABLE IF EXISTS` and `CREATE SCHEMA IF NOT EXISTS`.
    - Converts SQL Server types/expressions to PostgreSQL equivalents.
===============================================================================
*/

CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.crm_cust_info CASCADE;
CREATE TABLE silver.crm_cust_info (
    cst_id             integer,
    cst_key            varchar(50),
    cst_firstname      varchar(50),
    cst_lastname       varchar(50),
    cst_marital_status varchar(50),
    cst_gndr           varchar(50),
    cst_create_date    date,
    dwh_create_date    timestamptz DEFAULT now()
);

DROP TABLE IF EXISTS silver.crm_prd_info CASCADE;
CREATE TABLE silver.crm_prd_info (
    prd_id          integer,
    cat_id          varchar(50),
    prd_key         varchar(50),
    prd_nm          varchar(50),
    prd_cost        integer,
    prd_line        varchar(50),
    prd_start_dt    date,
    prd_end_dt      date,
    dwh_create_date timestamptz DEFAULT now()
);

DROP TABLE IF EXISTS silver.crm_sales_details CASCADE;
CREATE TABLE silver.crm_sales_details (
    sls_ord_num     varchar(50),
    sls_prd_key     varchar(50),
    sls_cust_id     integer,
    sls_order_dt    date,
    sls_ship_dt     date,
    sls_due_dt      date,
    sls_sales       integer,
    sls_quantity    integer,
    sls_price       integer,
    dwh_create_date timestamptz DEFAULT now()
);

DROP TABLE IF EXISTS silver.erp_loc_a101 CASCADE;
CREATE TABLE silver.erp_loc_a101 (
    cid             varchar(50),
    cntry           varchar(50),
    dwh_create_date timestamptz DEFAULT now()
);

DROP TABLE IF EXISTS silver.erp_cust_az12 CASCADE;
CREATE TABLE silver.erp_cust_az12 (
    cid             varchar(50),
    bdate           date,
    gen             varchar(50),
    dwh_create_date timestamptz DEFAULT now()
);

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2 CASCADE;
CREATE TABLE silver.erp_px_cat_g1v2 (
    id              varchar(50),
    cat             varchar(50),
    subcat          varchar(50),
    maintenance     varchar(50),
    dwh_create_date timestamptz DEFAULT now()
);

