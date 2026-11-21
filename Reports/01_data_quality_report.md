# Data Quality Report
**Project:** Olist Data Engineering  
**Layer:** Clean Layer  
**Database:** SQL Server  
**Report:** 01 – Data Quality Report

## 1. Overview

The purpose of this report is to document the data quality assessment performed on the Olist dataset during the Clean Layer development.

The Clean Layer was designed to standardize data types, handle whitespace, validate records, identify duplicates, enforce data integrity, and investigate potential data quality issues.

The objective was to produce reliable and structured datasets for the subsequent Data Warehouse layer while preserving valid source information.

## 2. Clean Layer Tables

The following tables were created and validated in the Clean schema.

| Table Name | Record Count |
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

**Note:** The geolocations_deduplicated table is a derived dataset created by removing exact duplicate records from clean.geolocations.

## 3. Data Quality Checks Performed

The following data quality checks were performed across the Clean Layer.

### 3.1 Data Type Validation
- Converted source data into appropriate SQL Server data types.
- Validated numeric, decimal, and datetime conversions.
- Used TRY_CONVERT where applicable to identify conversion issues.

### 3.2 NULL Value Validation
- Checked required columns for NULL values.
- Identified optional attributes containing NULL values.
- Preserved legitimate missing values rather than replacing them with assumptions.

### 3.3 Duplicate Validation
- Checked primary key uniqueness.
- Identified exact duplicate records.
- Investigated repeated business identifiers where multiple records were valid.
- Created a deduplicated geolocation dataset.

### 3.4 Referential Integrity
- Validated relationships between customers, orders, sellers, products, order items, and payments.
- Checked for missing referenced records.
- Applied primary and foreign key constraints where appropriate.

### 3.5 Data Format and Range Validation
- Validated ZIP code prefix formats.
- Checked geographic coordinate ranges.
- Validated order statuses and review scores.
- Investigated date and timestamp inconsistencies.

### 3.6 Data Reconciliation
- Compared staging and clean datasets using EXCEPT queries.
- Verified that expected records were preserved during transformations.
- Investigated differences introduced by intentional deduplication.

## 4. Important Data Quality Findings

The validation process identified several source-data conditions that required investigation.

| Table | Finding | Treatment |
|---|---|---|
| Customers | Some customer ZIP prefixes did not match geolocation prefixes | Preserved and documented |
| Products | Some physical attributes were NULL | Preserved |
| Orders | Some canceled orders contained delivery-related timestamps | Investigated and documented |
| Order Payments | Payment sequence and payment value anomalies were identified | Preserved and documented |
| Order Payments | 303 orders had payment totals different from order item totals plus freight | Documented for further investigation |
| Geolocations | Exact duplicate records were identified | Separate deduplicated table created |
| Geolocations | Some ZIP prefixes were not used by customers or sellers | Preserved |

## 5. Geolocation Deduplication Results

The original geolocation dataset contained 1,000,163 records.

After identifying exact duplicates across all five columns, a separate deduplicated table was created.

| Metric | Result |
|---|---:|
| Original records | 1,000,163 |
| Deduplicated records | 738,300 |
| Excess duplicate records removed | 261,863 |
| Distinct ZIP prefixes in deduplicated data | 19,015 |
| Unmatched records against original clean dataset | 0 |

The original clean.geolocations table was retained. Deduplication was performed in a separate table to preserve the original cleaned dataset.

## 6. Data Quality Approach

The cleaning process followed these principles:

- Preserve valid source information.
- Avoid deleting records without sufficient evidence.
- Distinguish between genuine data errors and legitimate business scenarios.
- Document anomalies that cannot be confidently corrected.
- Maintain data integrity through constraints and validation queries.
- Keep transformation and validation logic reproducible.

## 7. Conclusion

The Clean Layer has undergone extensive data quality validation, including data type checks, NULL checks, duplicate analysis, referential integrity checks, geographic validation, and staging-to-clean reconciliation.

Identified source-data anomalies were investigated and documented rather than silently modified.

The resulting Clean Layer provides structured datasets for the next stage of the project: Data Warehouse development.

---

**Report Status:** Prepared  
**Next Report:** Data Transformation Report