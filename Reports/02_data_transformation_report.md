# Data Transformation Report

**Project:** Olist Data Engineering  
**Layer:** Clean Layer  
**Database:** SQL Server  
**Report:** 02 – Data Transformation Report

## 1. Overview

This report documents the data transformation activities performed during the development of the Olist Clean Layer.

The objective was to transform raw staging datasets into structured, standardized, and reliable SQL Server tables suitable for analytical processing and Data Warehouse development.

## 2. Source and Target

**Source:** dbo schema (Staging Layer)

**Target:** clean schema (Clean Layer)

Data was transferred from staging tables into clean tables using SQL transformation scripts.

## 3. Transformation Techniques

### 3.1 Data Type Conversion

Source columns were converted into appropriate SQL Server data types.

Examples include:

- VARCHAR for textual identifiers and descriptions.
- INT for integer values where appropriate.
- DECIMAL for prices, weights, dimensions, and geographic coordinates.
- DATETIME2 for order and review timestamps.

TRY_CONVERT was used where applicable to identify values that could not be converted safely.

### 3.2 Whitespace Standardization

TRIM() was applied to relevant text columns to remove leading and trailing whitespace.

This helped standardize identifiers, city names, and other textual attributes.

### 3.3 NULL Handling

NULL values were investigated according to the meaning of each column.

Legitimate missing values were preserved rather than automatically replaced with default values.

### 3.4 Duplicate Identification

Duplicate analysis was performed using GROUP BY and HAVING COUNT(*) > 1.

Exact duplicate records were identified by comparing all relevant columns.

For geolocation data, a separate deduplicated table was created using SELECT DISTINCT.

### 3.5 Data Integrity Constraints

Primary key and foreign key constraints were applied where appropriate.

These constraints help maintain uniqueness and relationships between related datasets.

### 3.6 Data Validation

Validation queries were executed to check:

- Required fields and NULL values.
- Primary key uniqueness.
- Duplicate records.
- Geographic coordinate ranges.
- ZIP code prefix formats.
- Valid order statuses and review scores.
- Relationships between related tables.

## 4. Table-Level Transformations

| Target Table | Main Transformation Activities |
|---|---|
| clean.customers | Data type standardization, trimming, key validation |
| clean.seller | Text standardization, ZIP format checks, key validation |
| clean.products | Numeric conversion, NULL investigation, category validation |
| clean.product_category_name_translation | Text standardization and mapping validation |
| clean.geolocations | Coordinate conversion, geographic validation, ZIP format validation |
| clean.geolocations_deduplicated | Exact duplicate removal using SELECT DISTINCT |
| clean.orders | Timestamp conversion, status validation, relationship checks |
| clean.order_items | Numeric conversion, key validation, price and freight checks |
| clean.order_payments | Numeric conversion, payment validation, composite key |
| clean.order_reviews | Timestamp and review score validation, composite key |

## 5. Geolocation Deduplication

The original clean.geolocations table was retained.

A separate table, clean.geolocations_deduplicated, was created using SELECT DISTINCT across all five columns.

This approach preserved the original cleaned dataset while providing a separate dataset without exact duplicate rows.

## 6. Data Preservation Strategy

The transformation process followed a conservative data handling approach:

- No source records were removed without a clear reason.
- Legitimate NULL values were preserved.
- Business-related duplicates were distinguished from exact duplicate records.
- Source anomalies were documented instead of being silently corrected.
- The original cleaned geolocation dataset was retained alongside its deduplicated version.

## 7. Conclusion

The transformation process standardized the staging datasets and prepared them for analytical use.

Data type conversions, text standardization, duplicate analysis, integrity constraints, and validation checks were applied across the Clean Layer.

The resulting tables provide a structured foundation for the next phase of the Olist Data Engineering project: Data Warehouse development.

---

**Report Status:** Prepared  
**Previous Report:** 01_data_quality_report.md  
**Next Report:** 03_data_anomalies_report.md