# crm-erp-sql-data-warehouse
# SQL Data Warehouse Project

A small ELT-style SQL data warehouse demo using PostgreSQL schemas (bronze → silver → gold), PL/pgSQL load procedures, DDL for tables/views, and SQL quality checks.

## Skills & Technologies
- PostgreSQL (schemas, views, PL/pgSQL)
- ETL/ELT patterns (bronze/silver/gold)
- Server-side COPY and client-side \copy
- Data modeling (dimensions/facts), surrogate keys
- SQL-based data quality checks

## Repository Contents 
- [`LICENSE`](LICENSE)  
- [`README.md`](README.md)

Datasets:
- [datasets/source_crm/cust_info.csv](datasets/source_crm/cust_info.csv)  
- [datasets/source_crm/prd_info.csv](datasets/source_crm/prd_info.csv)  
- [datasets/source_crm/sales_details.csv](datasets/source_crm/sales_details.csv)  
- [datasets/source_erp/CUST_AZ12.csv](datasets/source_erp/CUST_AZ12.csv)  
- [datasets/source_erp/LOC_A101.csv](datasets/source_erp/LOC_A101.csv)  
- [datasets/source_erp/PX_CAT_G1V2.csv](datasets/source_erp/PX_CAT_G1V2.csv)

Docs:
- [docs/data_catalog.md](docs/data_catalog.md)  
- [docs/naming_conventions.md](docs/naming_conventions.md)

Scripts:
- [`scripts/init_database.sql`](scripts/init_database.sql) — creates DB & schemas  
- [`scripts/bronze/ddl_bronze.sql`](scripts/bronze/ddl_bronze.sql) — bronze DDL (tables)  
- [`scripts/bronze/proc_load_bronze.sql`](scripts/bronze/proc_load_bronze.sql) — bronze load procedure (`bronze.load_bronze_layer`)  
- [`scripts/silver/ddl_silver.sql`](scripts/silver/ddl_silver.sql) — silver DDL (tables)  
- [`scripts/silver/proc_load_silver.sql`](scripts/silver/proc_load_silver.sql) — silver load procedure (`silver.load_silver_layer`)  
- [`scripts/gold/ddl_gold.sql`](scripts/gold/ddl_gold.sql) — gold views (`gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`)

Tests / Quality Checks:
- [`tests/quality_checks_silver.sql`](tests/quality_checks_silver.sql)  
- [`tests/quality_checks_gold.sql`](tests/quality_checks_gold.sql)

## Key Symbols to Open
- [`bronze.load_bronze_layer`](scripts/bronze/proc_load_bronze.sql) — procedure to load Bronze  
- [`silver.load_silver_layer`](scripts/silver/proc_load_silver.sql) — procedure to load Silver  
- [`gold.dim_customers`](scripts/gold/ddl_gold.sql)  
- [`gold.dim_products`](scripts/gold/ddl_gold.sql)  
- [`gold.fact_sales`](scripts/gold/ddl_gold.sql)  
- [`bronze.crm_cust_info`](scripts/bronze/ddl_bronze.sql)  
- [`silver.crm_cust_info`](scripts/silver/ddl_silver.sql)

## Prerequisites
- PostgreSQL server (superuser for DB creation or a role with required privileges)  
- psql client or GUI (pgAdmin, DBeaver)  
- Ensure server process can access dataset CSV paths (or use client-side \copy)

## Quick Setup & Run (recommended)
1. Edit file paths in:
   - [`scripts/bronze/proc_load_bronze.sql`](scripts/bronze/proc_load_bronze.sql) — replace Windows server paths (e.g. `C:\\sql\\dwh_project\\datasets\\...`) with server-accessible absolute paths OR convert COPY to client-side `\copy` if running from psql.
2. (Optional) Fix dataset filenames/casing if needed to match the COPY paths in the script (repo has `CUST_AZ12.csv`, `LOC_A101.csv`, `PX_CAT_G1V2.csv`).
3. From a shell with psql (superuser):
   - psql -f scripts/init_database.sql
4. Run DDLs (connect to DataWarehouse first if needed):
   - psql -d "DataWarehouse" -f scripts/bronze/ddl_bronze.sql
   - psql -d "DataWarehouse" -f scripts/silver/ddl_silver.sql
   - psql -d "DataWarehouse" -f scripts/gold/ddl_gold.sql
5. Load data:
   - In psql or GUI: CALL bronze.load_bronze_layer(); — see [`bronze.load_bronze_layer`](scripts/bronze/proc_load_bronze.sql)
   - Then: CALL silver.load_silver_layer(); — see [`silver.load_silver_layer`](scripts/silver/proc_load_silver.sql)
6. Run quality checks:
   - psql -d "DataWarehouse" -f tests/quality_checks_silver.sql
   - psql -d "DataWarehouse" -f tests/quality_checks_gold.sql

## Required/Recommended Changes Before Running
- Update file paths in [`scripts/bronze/proc_load_bronze.sql`](scripts/bronze/proc_load_bronze.sql) to point to actual CSV locations accessible to the server or use client-side `\copy`.
- Ensure filename casing/names in the script match files under [datasets/](datasets/).
- If you cannot run server-side COPY, replace COPY with `\copy` or use a client import tool.
- Confirm you have privileges to create/drop databases (required by [`scripts/init_database.sql`](scripts/init_database.sql)).
- .gitignore currently ignores `*.csv` — ensure dataset CSVs are present locally even if they are not tracked.

## Notes
- The bronze load uses server-side COPY; change to client-side `\copy` when running from a local psql client without server file access.  
- Gold layer is implemented as views in [`scripts/gold/ddl_gold.sql`](scripts/gold/ddl_gold.sql).  
- Naming and modelling guidance is in [docs/naming_conventions.md](docs/naming_conventions.md) and [docs/data_catalog.md](docs/data_catalog.md).

## Running Tips
- Use a transaction or run each DDL independently for easier debugging.  
- Inspect RAISE NOTICE output when calling procedures in GUI tools for timing and errors.
