# Olist E-Commerce Data Engineering Project

An end-to-end data engineering portfolio project built using the Brazilian Olist E-Commerce Public Dataset. The project demonstrates data ingestion, data quality validation, data cleaning, transformation, and data warehouse development using Python and SQL Server.

## Project Overview

The goal of this project is to build a practical data engineering pipeline that transforms raw e-commerce data into reliable, structured data for analytical purposes.

The pipeline follows a layered approach:

1. Raw data ingestion
2. Staging layer
3. Data quality validation
4. Clean layer
5. Data warehouse
6. Analytics and reporting

Each layer is developed and validated before moving to the next stage.

## Technologies Used

- **Python** – Data ingestion and processing
- **Pandas** – Data inspection and manipulation
- **SQL Server** – Database management and data transformation
- **SQL** – Data validation, cleaning, and transformation
- **PyODBC** – Python-to-SQL Server connectivity
- **Git & GitHub** – Version control and project documentation

## Dataset

The project uses the Brazilian Olist E-Commerce Public Dataset.

The dataset contains information about:

- Customers
- Sellers
- Orders
- Order items
- Payments
- Reviews
- Products
- Product categories
- Geolocation data

## Project Architecture

```text
Olist CSV Files
      |
      v
Python Data Ingestion
      |
      v
SQL Server Database
      |
      v
Staging Layer (dbo)
      |
      v
Data Quality Validation
      |
      v
Clean Layer
      |
      v
Data Warehouse (Planned)
      |
      v
Analytics & Reporting (Planned)
```

## Database Information

**Database Name:** `OlistDataWarehouse`

The project currently contains nine staging tables and ten clean-layer tables.

### Staging Layer

| Staging Table | Records |
|---|---:|
| stg_customers | 99,441 |
| stg_geolocations | 1,000,163 |
| stg_order_items | 112,650 |
| stg_order_payments | 103,886 |
| stg_order_reviews | 99,224 |
| stg_orders | 99,441 |
| stg_product_category_name_translation | 71 |
| stg_products | 32,951 |
| stg_sellers | 3,095 |

### Clean Layer

| Clean Table | Records |
|---|---:|
| clean.customers | 99,441 |
| clean.seller | 3,095 |
| clean.products | 32,951 |
| clean.product_category_name_translation | 71 |
| clean.geolocations | 1,000,163 |
| clean.geolocations_deduplicated | 738,300 |
| clean.orders | 99,441 |
| clean.order_items | 112,650 |
| clean.order_payments | 103,886 |
| clean.order_reviews | 99,224 |

The original geolocation records are preserved in `clean.geolocations`. A separate deduplicated table contains 738,300 unique complete geolocation records.

## Project Progress

### Phase 1: Data Ingestion — Completed

- [x] Downloaded the Olist dataset.
- [x] Inspected CSV files using Python and Pandas.
- [x] Created the SQL Server database.
- [x] Created nine staging tables.
- [x] Loaded the source dataset into SQL Server.

### Phase 2: Data Quality Validation — Completed

- [x] Duplicate detection
- [x] NULL and empty-value detection
- [x] Invalid data detection
- [x] Numeric range validation
- [x] Date format and chronology validation
- [x] Primary and business key checks
- [x] Foreign key validation
- [x] Geographic consistency checks
- [x] Category translation mapping checks
- [x] Payment and order reconciliation checks

### Phase 3: Data Cleaning and Transformation — Completed

- [x] Reviewed identified data quality issues.
- [x] Defined cleaning and transformation rules.
- [x] Created clean-layer tables.
- [x] Applied data type conversions and standardization.
- [x] Handled duplicate geolocation records separately.
- [x] Validated clean-layer row counts.
- [x] Performed staging-to-clean reconciliation checks.
- [x] Completed final validation of all clean tables.
- [x] Documented data anomalies and transformation decisions.

### Phase 4: Data Warehouse Development — Upcoming

- [ ] Design the dimensional data warehouse.
- [ ] Define fact table grain and business processes.
- [ ] Design dimension tables.
- [ ] Create fact tables.
- [ ] Implement surrogate keys and relationships.
- [ ] Develop data warehouse loading processes.
- [ ] Validate warehouse data.

### Phase 5: Analytics and Reporting — Planned

- [ ] Develop analytical SQL queries.
- [ ] Create business performance metrics.
- [ ] Analyze customer and seller performance.
- [ ] Analyze sales, payments, and delivery performance.
- [ ] Build dashboards and reports.

## Data Quality Findings

The validation and cleaning process identified several source-data anomalies. These were documented rather than silently treated as invalid records.

Some important findings include:

### Customers and Geolocation

- 157 distinct customer ZIP prefixes did not match the available geolocation ZIP prefixes, affecting 278 customer records.
- 4,099 geolocation ZIP prefixes were not used by either customers or sellers. These records were preserved.
- The original geolocation table contains 1,000,163 records, while the deduplicated table contains 738,300 unique complete records.

### Products

- 610 products have missing attributes or category information.
- Two products have all physical attributes missing.
- Four products have zero weight despite having dimensional information.
- Thirteen products belong to categories without a matching English translation.

### Orders and Delivery

- 1,359 orders have carrier timestamps earlier than their approval timestamps.
- Six canceled orders contain customer delivery timestamps.
- Seventy-five canceled orders contain carrier delivery timestamps.
- 10,423 order items were shipped after their shipping deadlines.

### Payments

- Nine payment records have zero payment values.
- Two credit-card payment records have zero installments.
- Eighty orders have unusual payment sequence patterns.
- 303 orders have differences between payment totals and their corresponding item-plus-freight totals.

These findings are retained as documented data anomalies. They are not automatically assumed to be errors without sufficient evidence.

## Documentation

The Clean layer documentation is maintained in the `reports/` directory.

| Report | Description |
|---|---|
| `01_data_quality_report.md` | Data quality checks and validation results |
| `02_data_transformation_report.md` | Cleaning and transformation methods |
| `03_data_anomalies_report.md` | Identified source-data anomalies |
| `04_data_reconciliation_report.md` | Staging-to-clean reconciliation results |
| `05_data_dictionary.md` | Clean-layer tables and column descriptions |

## SQL Scripts

SQL scripts are used for data validation, cleaning, transformation, and reconciliation.

The project includes the cleaning and transformation work in:

- `04_Cleaning_And_Transformation.sql`

Additional scripts and documentation are maintained in their respective project directories.

## Project Goals

The main objectives are to:

1. Develop practical data engineering skills.
2. Build an end-to-end data pipeline using a real-world dataset.
3. Improve Python and SQL Server skills.
4. Understand data quality, data cleaning, and transformation.
5. Learn dimensional modeling and data warehouse concepts.
6. Build a portfolio project demonstrating practical data engineering experience.

## Author

**Data Engineering Portfolio Project**

Technologies: Python | Pandas | SQL Server | SQL | PyODBC | Git | GitHub