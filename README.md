# crm-erp-sql-data-warehouse

## 1 — Overview
A small ELT-style SQL data warehouse demo built with PostgreSQL. Demonstrates Bronze → Silver → Gold layering, PL/pgSQL load procedures, DDL for tables/views, and SQL-based data quality checks. Intended as a learning/example project and a lightweight starting point for small analytic workloads.

## 2 — Repository Purpose
- Demonstrate practical patterns for organizing an ELT pipeline inside PostgreSQL using schemas and stored procedures.
- Provide example datasets, DDL, load procedures and quality checks so you can run the whole stack locally or on a server with minimal changes.

## 3 — Skills & Technologies Applied
- PostgreSQL (schemas, roles, permissions, views)
- PL/pgSQL (stored procedures for layer loads)
- ELT/ETL patterns (bronze/silver/gold layering)
- Server-side `COPY` and client-side `\copy`
- Data modeling (dimensions/facts, surrogate keys, star schema)
- SQL views for semantic (gold) layer
- SQL-based data quality checks and test queries
- DDL management and transactional DDL patterns
- Git for source control
- Shell/psql automation

## 4 — Repository Structure (categorized)
Top-level
- [LICENSE](LICENSE)  
- [README.md](README.md)

Datasets
- [datasets/source_crm/cust_info.csv](datasets/source_crm/cust_info.csv)  
- [datasets/source_crm/prd_info.csv](datasets/source_crm/prd_info.csv)  
- [datasets/source_crm/sales_details.csv](datasets/source_crm/sales_details.csv)  
- [datasets/source_erp/CUST_AZ12.csv](datasets/source_erp/CUST_AZ12.csv)  
- [datasets/source_erp/LOC_A101.csv](datasets/source_erp/LOC_A101.csv)  
- [datasets/source_erp/PX_CAT_G1V2.csv](datasets/source_erp/PX_CAT_G1V2.csv)

Documentation
- [docs/data_catalog.md](docs/data_catalog.md)  
- [docs/naming_conventions.md](docs/naming_conventions.md)

Scripts
- Initialization
  - [scripts/init_database.sql](scripts/init_database.sql) — creates DB & schemas
- Bronze (raw ingestion)
  - [scripts/bronze/ddl_bronze.sql](scripts/bronze/ddl_bronze.sql) — bronze DDL (tables)  
  - [scripts/bronze/proc_load_bronze.sql](scripts/bronze/proc_load_bronze.sql) — bronze load procedure (`bronze.load_bronze_layer`)
- Silver (cleaned/enriched)
  - [scripts/silver/ddl_silver.sql](scripts/silver/ddl_silver.sql) — silver DDL (tables)  
  - [scripts/silver/proc_load_silver.sql](scripts/silver/proc_load_silver.sql) — silver load procedure (`silver.load_silver_layer`)
- Gold (semantic/views)
  - [scripts/gold/ddl_gold.sql](scripts/gold/ddl_gold.sql) — gold views (`gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`)

Tests / Quality Checks
- [tests/quality_checks_silver.sql](tests/quality_checks_silver.sql)  
- [tests/quality_checks_gold.sql](tests/quality_checks_gold.sql)

Note: This categorized list highlights main files and folders. To view every file at the repository commit, run `git ls-tree -r --name-only HEAD` locally or view the repo tree in the GitHub UI.

## 5 — Prerequisites
- PostgreSQL server (superuser required to run provided DB create/drop, or use a role with required privileges)
- psql client or GUI (pgAdmin, DBeaver)
- Local checkout of the repository and dataset CSVs (note: `.gitignore` may exclude `*.csv`)
- If using server-side `COPY`, the PostgreSQL server process must have filesystem access to dataset paths

## 6 — Required / Recommended Changes Before Running
1. Update COPY paths in [scripts/bronze/proc_load_bronze.sql](scripts/bronze/proc_load_bronze.sql):
   - Replace example Windows server paths (e.g. `C:\\sql\\dwh_project\\datasets\\...`) with server-accessible absolute paths, or switch to client `\copy` for local runs.
2. Confirm filename casing and names in `datasets/` match the COPY commands (Linux servers are case-sensitive).
3. Ensure running role has privileges to create DBs/schemas/tables. If not, run only schema/table DDLs or ask a DBA to run `scripts/init_database.sql`.
4. Ensure CSV files are present locally (they may be ignored by `.gitignore`).
5. Adjust line endings, encoding, delimiters as necessary for your environment.

## 7 — Quick Setup & Run (recommended)
1. Clone and (optionally) checkout specific commit:
   - git clone https://github.com/Manojkumarw13/crm-erp-sql-data-warehouse.git
   - cd crm-erp-sql-data-warehouse
   - git checkout 22c1a503de7fb6212db87ff32cb6bf509326c6fe
2. Edit server/client COPY paths in `scripts/bronze/proc_load_bronze.sql` or plan to use `\copy`.
3. Create DB & schemas (as role with privileges):
   - psql -f scripts/init_database.sql
   - Or, if no DB create privileges: connect to your target DB and run schema/DDL scripts only.
4. Run DDLs (connect to DataWarehouse DB if created):
   - psql -d "DataWarehouse" -f scripts/bronze/ddl_bronze.sql
   - psql -d "DataWarehouse" -f scripts/silver/ddl_silver.sql
   - psql -d "DataWarehouse" -f scripts/gold/ddl_gold.sql
5. Load data:
   - Server-side COPY (if server can access files):
     - psql -d "DataWarehouse" -c "CALL bronze.load_bronze_layer();"
   - Client-side \copy (recommended for local dev):
     - psql -d "DataWarehouse"
       - \copy bronze.crm_cust_info FROM 'datasets/source_crm/cust_info.csv' CSV HEADER
       - (repeat for other CSVs or use adapted loader)
     - Then run: psql -d "DataWarehouse" -c "CALL silver.load_silver_layer();"
6. Run quality checks:
   - psql -d "DataWarehouse" -f tests/quality_checks_silver.sql
   - psql -d "DataWarehouse" -f tests/quality_checks_gold.sql

## 8 — Recommended Development Workflow
- Apply DDLs and loads step-by-step in transactions for easier debugging.
- Use `RAISE NOTICE` outputs in procedures to monitor progress and timing.
- Run quality checks after each layer (bronze → silver → gold).
- Keep tests and sample datasets updated for reproducibility.

## 9 — Troubleshooting (common issues)
- COPY permission error: server cannot read the file. Use `\copy` or ensure server-file permissions and location.
- Filename/case mismatch: adjust paths or rename files.
- Encoding issues: convert CSVs or specify encoding (e.g. `ENCODING 'UTF8'`).
- Missing DB creation privileges: run only schema/DDL as available role or ask DBA to run `init_database.sql`.

## 10 — What changed in this README
- Added clear headings and categorized sections for easier discovery.
- Expanded and clarified Quick Setup & Run and Required Changes.
- Collected technologies and a short repo purpose note.

## 11 — Next actions I can take
- Commit this organized README to a new branch and open a PR.
- Add commented `\copy` examples to `scripts/bronze/proc_load_bronze.sql`.
- Create a small run script to automate the steps for local development.

If you want me to commit and open a PR, tell me the branch name to use or I can propose one.
