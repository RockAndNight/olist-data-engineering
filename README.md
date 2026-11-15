# Olist E-Commerce Data Engineering Project

An end-to-end data engineering project using the Brazilian Olist E-Commerce dataset. The project focuses on building a data pipeline using Python, SQL Server, and data quality validation techniques.

## Project Overview

The goal of this project is to build a data engineering pipeline that processes raw e-commerce data, validates data quality, and prepares structured data for analytical purposes.

The project follows a step-by-step approach, starting with raw data ingestion and progressing toward data transformation and data warehouse development.

## Technologies Used

- **Python** – Data ingestion and processing
- **Pandas** – Data inspection and manipulation
- **SQL Server** – Database and staging layer
- **SQL** – Data validation and transformation
- **PyODBC** – Python-to-SQL Server connectivity
- **Git & GitHub** – Version control and project documentation

## Dataset

The project uses the Olist Brazilian E-Commerce Public Dataset.

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

The planned data pipeline follows this structure:

```text
Olist CSV Files
      |
      v
Python Data Ingestion
      |
      v
SQL Server
      |
      v
Staging Tables
      |
      v
Data Quality Validation
      |
      v
Data Cleaning & Transformation
      |
      v
Data Warehouse
      |
      v
Analytics & Reporting
```

## Database Information

Database name: `OlistDataWarehouse`

The raw dataset has been loaded into nine SQL Server staging tables.

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

## Project Progress

### Phase 1: Data Ingestion

- [x] Downloaded the Olist dataset.
- [x] Inspected CSV files using Python and Pandas.
- [x] Created the SQL Server database.
- [x] Created staging tables.
- [x] Loaded the dataset into SQL Server.

### Phase 2: Data Quality Validation

- [x] Duplicate detection
- [x] NULL and empty-value detection
- [x] Invalid data detection
- [x] Numeric range validation
- [x] Date format and chronology validation
- [x] Primary/business key checks
- [x] Foreign key validation
- [x] Geographic consistency checks
- [x] Category translation mapping checks

### Phase 3: Data Cleaning and Transformation

- [ ] Investigate identified data quality issues.
- [ ] Define data cleaning rules.
- [ ] Transform staging data.
- [ ] Create clean tables.

### Phase 4: Data Warehouse Development

- [ ] Design the data warehouse schema.
- [ ] Create dimension tables.
- [ ] Create fact tables.
- [ ] Implement data loading processes.

### Phase 5: Analytics

- [ ] Develop analytical SQL queries.
- [ ] Create business performance metrics.
- [ ] Build dashboards and reports.

## Data Quality Findings

During validation, several issues and anomalies were identified:

- 610 products have NULL category names.
- 13 products have category names without matching English translations.
- 1,359 orders have carrier timestamps earlier than approval timestamps.
- 531 order items have freight charges at least twice their item prices.
- 8 geolocation ZIP prefixes have records associated with multiple states.
- Some payment records have zero values or unusual installment information.

These findings are documented for further investigation. No source staging records were modified or deleted during validation.

## SQL Scripts

| Script | Description |
|---|---|
| `01_duplicate_detection.sql` | Identifies duplicate business keys |
| `02_null_detection.sql` | Checks NULL and empty values |
| `03_invalid_data_detection.sql` | Validates formats, ranges, relationships, and other data quality rules |

Detailed findings are available in:

`docs/data-quality-report.md`

## Project Goals

The main objectives are to:

1. Develop practical data engineering skills.
2. Build a complete data pipeline using real-world data.
3. Improve SQL and Python skills.
4. Understand data quality and data warehouse concepts.
5. Build a portfolio project demonstrating practical data engineering experience.

## Author

**Data Engineering Portfolio Project**

Technologies: Python | SQL Server | Pandas | PyODBC | GitHub
