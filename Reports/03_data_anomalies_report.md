# Data Anomalies Report

**Project:** Olist Data Engineering  
**Layer:** Clean Layer  
**Database:** SQL Server  
**Report:** 03 – Data Anomalies Report

## 1. Overview

This report documents data anomalies and irregularities identified during the cleaning and validation of the Olist dataset.

The purpose is to provide transparency about source-data issues, distinguish legitimate business scenarios from potential inconsistencies, and document how each finding was handled.

Identified anomalies were investigated using SQL queries and, where applicable, compared against the original staging data.

## 2. Customer Data Anomalies

### 2.1 Customer ZIP Prefixes Without Geolocation Matches

- 14,994 distinct customer ZIP prefixes were identified.
- 14,837 ZIP prefixes matched the geolocation dataset.
- 157 distinct ZIP prefixes did not match.
- These unmatched prefixes affected 278 customer records.

**Treatment:** Records were preserved. No ZIP prefixes were automatically modified or deleted.

## 3. Seller Data Anomalies

During seller data cleaning, several city-name inconsistencies and formatting issues were identified.

Examples included:
- Inconsistent capitalization.
- Extra spaces.
- City names containing state names.
- Misspellings and inconsistent city representations.

Some city-name corrections were based on geolocation evidence and should be treated as inferred corrections rather than independently verified facts.

**Treatment:** Standardization and documented corrections were applied where appropriate.

## 4. Product Data Anomalies

### 4.1 Missing Physical Attributes

Some products contained NULL values in physical attribute columns.

Two products were identified with all physical attributes missing.

**Treatment:** NULL values were preserved because there was insufficient evidence to determine the correct physical measurements.

### 4.2 Zero Product Weight

Four products had a recorded weight of zero while having dimension values.

These values were also present in the staging dataset.

**Treatment:** Values were preserved as source-data conditions.

### 4.3 Missing Category Translations

Thirteen products belonged to categories without a corresponding English translation.

- portateis_cozinha_e_preparadores_de_alimentos: 10 products
- pc_gamer: 3 products

**Treatment:** Original category values were preserved. Missing translations were not invented.

## 5. Order Data Anomalies

### 5.1 Delivery Timestamps in Canceled Orders

Among 625 canceled orders:
- 6 contained customer delivery timestamps.
- 75 contained carrier delivery timestamps.

Some records had sequential timestamps despite having canceled status.

**Treatment:** Original statuses and timestamps were preserved and documented for further investigation.

## 6. Order Item Anomalies

### 6.1 Late Shipments

- 10,423 order items had shipment dates later than their shipping deadlines.
- 1,194 order items did not have carrier delivery dates.
- 8,861 orders were identified as late out of 98,666 relevant orders (approximately 8.98%).

Some canceled orders also contained late-shipment conditions.

**Treatment:** Original dates were preserved to support delivery performance analysis.

## 7. Order Payment Anomalies

### 7.1 Zero Payment Values

Nine payment records had a payment value of zero:
- 6 voucher records.
- 3 not_defined records.

### 7.2 Zero Credit Card Installments

Two credit card payment records contained zero installments.

These values were confirmed in the staging dataset.

### 7.3 Payment Sequence Irregularities

Eighty orders contained unusual payment sequence patterns:
- 78 orders contained only sequence number 2.
- 2 orders contained sequence numbers 2 and 3.

These conditions were also confirmed against staging data.

### 7.4 Payment and Order Item Total Differences

A total of 303 orders had differences between payment totals and order item totals plus freight.

The largest identified difference was:

- Order ID: ce6d150fb29ada17d2082f4847107665
- Payment total: 1,586.47
- Order items plus freight: 1,403.66
- Difference: 182.81

**Treatment:** Payment values were preserved. The cause of these differences was not conclusively established.

## 8. Geolocation Data Anomalies

### 8.1 Exact Duplicate Records

The original geolocation dataset contained exact duplicate records.

- Original records: 1,000,163
- Unique full records: 738,300
- Excess duplicate records: 261,863

**Treatment:** The original clean.geolocations table was preserved. A separate clean.geolocations_deduplicated table was created.

### 8.2 ZIP Prefixes Not Used by Customers or Sellers

A validation query identified 4,099 distinct geolocation ZIP prefixes that were not used by either customers or sellers.

**Treatment:** These records were preserved because they may represent valid locations outside the current customer and seller records.

## 9. Anomaly Handling Principles

The following principles were followed throughout the cleaning process:

- Preserve original source information wherever possible.
- Do not assume every unusual value is an error.
- Confirm suspected anomalies against staging data.
- Avoid inventing missing values.
- Document inferred corrections and their assumptions.
- Keep separate datasets when deduplication is required.
- Retain unresolved anomalies for future investigation.

## 10. Conclusion

The Olist dataset contained several irregularities involving customer ZIP prefixes, product attributes, order timestamps, payment values, shipment deadlines, and geolocation duplicates.

These findings were investigated and documented during the Clean Layer development.

Where the correct value or explanation could not be established confidently, the original data was preserved.

This report provides a record of known source-data conditions that should be considered during Data Warehouse development and subsequent business analysis.

---

**Report Status:** Prepared  
**Previous Report:** 02_data_transformation_report.md  
**Next Report:** 04_data_reconciliation_report.md