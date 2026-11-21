# Data Reconciliation Report

**Project:** Olist Data Engineering  
**Layer:** Clean Layer  
**Database:** SQL Server  
**Report:** 04 – Data Reconciliation Report

## 1. Overview

This report documents the reconciliation activities performed between the Staging and Clean Layers of the Olist Data Engineering project.

The objective was to verify that records were transferred correctly, transformations did not introduce unintended data loss, and relationships between datasets remained consistent.

## 2. Source and Target Schemas

| Layer | Schema | Description |
|---|---|---|
| Staging | dbo | Source data loaded from CSV files |
| Clean | clean | Standardized and validated datasets |

## 3. Record Count Reconciliation

The following record counts were recorded for the staging and clean datasets.

| Dataset | Staging Records | Clean Records |
|---|---:|---:|
| Customers | 99,441 | 99,441 |
| Sellers | 3,095 | 3,095 |
| Products | 32,951 | 32,951 |
| Product Category Translation | 71 | 71 |
| Geolocations | 1,000,163 | 1,000,163 |
| Orders | 99,441 | 99,441 |
| Order Items | 112,650 | 112,650 |
| Order Payments | 103,886 | 103,886 |
| Order Reviews | 99,224 | 99,224 |

The geolocations_deduplicated table is a derived table and does not have a direct one-to-one staging record count comparison.

## 4. Data Comparison Method

SQL Server EXCEPT queries were used to compare staging and clean datasets.

Two-way comparisons were performed where applicable:

- Staging EXCEPT Clean
- Clean EXCEPT Staging

This approach helped identify records that existed in one dataset but not the other.

The comparisons returned no unmatched records for the datasets where this reconciliation was performed.

## 5. Referential Integrity Reconciliation

Relationships between related tables were validated using SQL queries.

The checks included:

- Customer references in orders.
- Order references in order items.
- Order references in payments.
- Order references in reviews.
- Product references in order items.
- Seller references in order items.

Foreign key validation was used to identify missing referenced records.

## 6. Geolocation Reconciliation

The original cleaned geolocation dataset contained 1,000,163 records.

A separate deduplicated dataset was created.

| Metric | Records |
|---|---:|
| Original clean geolocations | 1,000,163 |
| Deduplicated geolocations | 738,300 |
| Excess exact duplicate records | 261,863 |
| Unmatched deduplicated records against original clean dataset | 0 |

The deduplicated dataset was created using SELECT DISTINCT across all five columns.

## 7. Reconciliation Findings

The reconciliation process confirmed that:

- Staging and Clean record counts matched for the listed base datasets.
- Two-way EXCEPT comparisons returned no unmatched records where performed.
- Referential integrity checks were performed on relevant relationships.
- Geolocation deduplication was performed separately without replacing the original clean table.
- Identified source-data anomalies were preserved and documented.

## 8. Conclusion

The reconciliation activities provided evidence that the Clean Layer transformations preserved the expected source records for the datasets compared.

Record counts, dataset comparisons, and referential integrity checks were used to validate the transformation process.

The Clean Layer is now documented as the structured source for the next phase of the project: Data Warehouse development.

---

**Report Status:** Prepared  
**Previous Report:** 03_data_anomalies_report.md  
**Next Report:** 05_data_dictionary.md