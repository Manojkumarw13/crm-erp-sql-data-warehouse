/*
===============================================================================
DDL Script: Create Bronze Tables (PostgreSQL)
===============================================================================
Script Purpose:
    This script creates tables in the "bronze" schema, dropping existing tables
    if they already exist. It is a PostgreSQL-compatible translation of the
    original T-SQL DDL.

USAGE:
    Run with the psql client as a role that can create/drop objects in the
    target database. The `init_database.sql` script should already create the
    `bronze` schema; this file will ensure the schema exists as well.

WARNING:
    Dropping tables will remove all data in them.
===============================================================================
*/

-- Ensure schema exists
CREATE SCHEMA IF NOT EXISTS bronze;

-- Customer info
DROP TABLE IF EXISTS bronze.crm_cust_info CASCADE;
CREATE TABLE bronze.crm_cust_info (
    cst_id              integer,
    cst_key             varchar(50),
    cst_firstname       varchar(50),
    cst_lastname        varchar(50),
    cst_marital_status  varchar(50),
    cst_gndr            varchar(50),
    cst_create_date     date
);

-- Product info
DROP TABLE IF EXISTS bronze.crm_prd_info CASCADE;
CREATE TABLE bronze.crm_prd_info (
    prd_id       integer,
    prd_key      varchar(50),
    prd_nm       varchar(50),
    prd_cost     integer,
    prd_line     varchar(50),
    prd_start_dt timestamp without time zone,
    prd_end_dt   timestamp without time zone
);

-- Sales details
DROP TABLE IF EXISTS bronze.crm_sales_details CASCADE;
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  varchar(50),
    sls_prd_key  varchar(50),
    sls_cust_id  integer,
    sls_order_dt integer,
    sls_ship_dt  integer,
    sls_due_dt   integer,
    sls_sales    integer,
    sls_quantity integer,
    sls_price    integer
);

-- ERP location
DROP TABLE IF EXISTS bronze.erp_loc_a101 CASCADE;
CREATE TABLE bronze.erp_loc_a101 (
    cid    varchar(50),
    cntry  varchar(50)
);

-- ERP customer
DROP TABLE IF EXISTS bronze.erp_cust_az12 CASCADE;
CREATE TABLE bronze.erp_cust_az12 (
    cid    varchar(50),
    bdate  date,
    gen    varchar(50)
);

-- Product category
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2 CASCADE;
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           varchar(50),
    cat          varchar(50),
    subcat       varchar(50),
    maintenance  varchar(50)
);

-- End of script

