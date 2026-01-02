# crm-erp-sql-data-warehouse

Short note
This repository is a small ELT-style SQL data warehouse demo built with PostgreSQL. It demonstrates Bronze → Silver → Gold layering, PL/pgSQL load procedures, DDL for tables and views, and SQL-based data quality checks. It's intended as a learning/example project and a lightweight starting point for small analytic workloads.

Repository purpose
- Show practical patterns for organizing an ELT pipeline inside a PostgreSQL database using schemas and stored procedures.
- Provide example datasets, DDL, load procedures and quality checks so you can run the whole stack locally or on a server with minimal changes.

Key skills & technologies applied
- PostgreSQL (schemas, roles, permissions)
- PL/pgSQL (stored procedures for layer loads)
- ELT/ETL patterns (bronze/silver/gold layering)
- Server-side COPY and client-side `\copy`
- Data modeling (dimensions/facts, surrogate keys, star schema)
- SQL views for semantic (gold) layer
- SQL-based data quality checks and test queries
- DDL management and transactional DDL patterns
- Git for source control and reproducible deployments
- Basic shell/psql automation

Repository contents (high level)
- [LICENSE](LICENSE)  
- [README.md](README.md) (this file)
- datasets/
  - [datasets/source_crm/cust_info.csv](datasets/source_crm/cust_info.csv)  
  - [datasets/source_crm/prd_info.csv](datasets/source_crm/prd_info.csv)  
  - [datasets/source_crm/sales_details.csv](datasets/source_crm/sales_details.csv)  
  - [datasets/source_erp/CUST_AZ12.csv](datasets/source_erp/CUST_AZ12.csv)  
  - [datasets/source_erp/LOC_A101.csv](datasets/source_erp/LOC_A101.csv)  
  - [datasets/source_erp/PX_CAT_G1V2.csv](datasets/source_erp/PX_CAT_G1V2.csv)
- docs/
  - [docs/data_catalog.md](docs/data_catalog.md)  
  - [docs/naming_conventions.md](docs/naming_conventions.md)
- scripts/
  - [scripts/init_database.sql](scripts/init_database.sql) — DB & schema creation  
  - scripts/bronze/
    - [scripts/bronze/ddl_bronze.sql](scripts/bronze/ddl_bronze.sql) — bronze DDL (tables)  
    - [scripts/bronze/proc_load_bronze.sql](scripts/bronze/proc_load_bronze.sql) — bronze load procedure (`bronze.load_bronze_layer`)  
  - scripts/silver/
    - [scripts/silver/ddl_silver.sql](scripts/silver/ddl_silver.sql) — silver DDL (tables)  
    - [scripts/silver/proc_load_silver.sql](scripts/silver/proc_load_silver.sql) — silver load procedure (`silver.load_silver_layer`)  
  - scripts/gold/
    - [scripts/gold/ddl_gold.sql](scripts/gold/ddl_gold.sql) — gold views (`gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`)
- tests/
  - [tests/quality_checks_silver.sql](tests/quality_checks_silver.sql)  
  - [tests/quality_checks_gold.sql](tests/quality_checks_gold.sql)

Note: The README lists the most relevant files but may not show every file in nested directories or hidden files. Use `git ls-tree -r --name-only HEAD` to see the full file list at the repository commit.

Prerequisites
- PostgreSQL server (a superuser is needed if you want the provided `scripts/init_database.sql` to create/drop the DB, or use a role with sufficient privileges)
- psql client or a GUI (pgAdmin, DBeaver)
- Shell with access to the repository and dataset CSVs
- If you plan server-side COPY, the PostgreSQL server process must have filesystem access to dataset paths

Required / recommended changes before running
1. Update COPY paths in [scripts/bronze/proc_load_bronze.sql](scripts/bronze/proc_load_bronze.sql)
   - The script contains server-side absolute paths (example: `C:\\sql\\dwh_project\\datasets\\...` on Windows). Change these to:
     - Server-accessible absolute paths if you will use server-side `COPY`, or
     - Use client-side `\copy` (recommended for local development) and supply the correct relative/absolute local paths.
2. Match dataset filenames and casing
   - Confirm filenames in `datasets/` match the names used by the COPY commands (case matters on many servers).
3. Privileges
   - Ensure the running role has required privileges to create databases/schemas/tables. If you cannot grant superuser, skip or modify `scripts/init_database.sql` and run only schema/table creation as the granted role.
4. .gitignore and datasets
   - The repo may ignore `*.csv`. Make sure the dataset CSVs are present locally even if not tracked.
5. Adjust any path or encoding specifics for your environment (line endings, delimiter, encoding).
6. If you prefer incremental or custom loads, review and adapt the PL/pgSQL procedures to your CI/production patterns.

Quick setup & run (recommended, commands)
1. Clone repository and optionally check out a specific commit:
   - git clone https://github.com/Manojkumarw13/crm-erp-sql-data-warehouse.git
   - cd crm-erp-sql-data-warehouse
   - (optional) git checkout 22c1a503de7fb6212db87ff32cb6bf509326c6fe
2. Edit server/client COPY paths:
   - Open `scripts/bronze/proc_load_bronze.sql` and update CSV paths or plan to run `\copy` manually.
3. Create database & schemas (as a role with appropriate privileges):
   - psql -f scripts/init_database.sql
   - Or (if you lack privileges) connect to your target DB and run only schema and DDL scripts (skip DB create).
4. Run DDLs (connect to `DataWarehouse` DB if created):
   - psql -d "DataWarehouse" -f scripts/bronze/ddl_bronze.sql
   - psql -d "DataWarehouse" -f scripts/silver/ddl_silver.sql
   - psql -d "DataWarehouse" -f scripts/gold/ddl_gold.sql
5. Load data
   - If server-side COPY paths are correct and accessible:
     - psql -d "DataWarehouse" -c "CALL bronze.load_bronze_layer();"
   - If using client-side \copy (from your repo root):
     - psql -d "DataWarehouse"
       - \i scripts/bronze/ddl_bronze.sql   -- ensure tables exist
       - \copy bronze.crm_cust_info FROM 'datasets/source_crm/cust_info.csv' CSV HEADER
       - (repeat for other files) or adapt `proc_load_bronze.sql` to use \copy patterns
     - Then call silver loader:
       - psql -d "DataWarehouse" -c "CALL silver.load_silver_layer();"
6. Run data quality checks
   - psql -d "DataWarehouse" -f tests/quality_checks_silver.sql
   - psql -d "DataWarehouse" -f tests/quality_checks_gold.sql

Recommended run approach for development
- Run DDLs and loads step-by-step in transactions or single statements to make debugging easier.
- Inspect `RAISE NOTICE` output in the stored procedures for timing and error information.
- Run quality checks after each layer to validate assumptions early.

Common errors and troubleshooting
- COPY permission error: server process cannot read the file. Use `\copy` (client-side) or move file to server-accessible location and ensure permissions.
- Filename/case mismatch: adjust paths or rename files (Linux/Unix systems are case-sensitive).
- Encoding issues: specify `ENCODING 'UTF8'` or convert CSVs if required.
- Missing privileges creating DB: run only schema/DDL as the available role, or ask a DBA to run `init_database.sql`.

What changed in this enhanced README (summary)
- Provided a clearer, step-by-step Quick Setup & Run section with commands for both server-side COPY and client-side `\copy`.
- Consolidated and expanded the “Required/Recommended Changes” to be explicit and actionable.
- Added a complete Skills & Technologies section and a short repo purpose note for clarity.
- Included troubleshooting pointers and recommended development workflow.

Next steps I can take for you
- I can commit this updated README to a new branch and open a pull request in the repository.
- I can also update the `scripts/bronze/proc_load_bronze.sql` to provide both server COPY and commented \copy examples if you want.
- If you prefer, I can generate a checklist or a small automated shell script to run these steps locally.

If you want me to commit these changes, tell me:
- The branch name to create (or I can propose one), and
- Whether to push directly to `main` (not recommended) or create a PR.

If you want me to make any other changes now (example: add \copy examples to the bronze loader or create a run script), tell me which and I’ll proceed.
