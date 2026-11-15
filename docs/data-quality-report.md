# Olist Dataset — Data Quality Validation Report

## 1. Objective

The objective of this phase was to assess the data quality of the Olist Brazilian E-commerce dataset before proceeding with data cleaning, transformation, and warehouse development.

Validation was performed using SQL Server on nine staging tables.

## 2. Tables Validated

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

## 3. Validation Categories

The following checks were performed:

- Duplicate record detection
- NULL and empty-value detection
- Data type and format validation
- Numeric range validation
- Date format and chronological validation
- Primary/business key uniqueness
- Foreign key and referential integrity checks
- Category translation mapping validation
- Geographic consistency checks

## 4. Important Findings

### Customers
- No NULL or duplicate customer IDs.
- ZIP prefixes passed format and numeric checks.
- All 27 expected Brazilian state codes were valid.
- Customer-to-order relationships passed.

### Geolocations
- Latitude values passed the expected range check.
- ZIP prefixes passed format validation.
- One city value contained a trailing space.
- Eight ZIP prefixes had records associated with multiple states. These were flagged for further investigation.

### Order Items
- Order item composite key was unique.
- All three foreign key relationships passed.
- 4,124 records had freight charges greater than item prices.
- 531 records had freight charges at least twice the item price. These were flagged as anomalies, not confirmed errors.

### Order Payments
- Nine records had zero payment values.
- Two credit card records had zero installments.
- Three records used the `not_defined` payment type.
- These records were flagged for investigation.

### Order Reviews
- Review scores passed the expected 1–5 range.
- Date format and review chronology checks were performed.

### Orders
- Order statuses matched the expected status list.
- Date format and chronology checks were performed.
- 1,359 records had carrier dates earlier than approval dates. These were flagged for investigation.

### Products
- Numeric product attributes were validated for data type and expected ranges.

### Sellers
- No NULL, empty, or duplicate seller IDs.
- ZIP prefix and state code validations passed.
- City name checks passed.
- All seller references from order items matched existing sellers.

### Product Category Translation
- Both Portuguese and English category columns passed NULL and empty-value checks.
- No duplicate category names were found in either column.
- 610 products had NULL category names.
- 13 products had non-NULL category names without a matching translation:
  - `portateis_cozinha_e_preparadores_de_alimentos`: 10 products
  - `pc_gamer`: 3 products

## 5. Conclusion

The initial data quality validation phase has been completed across all nine staging tables.

Several anomalies and missing values were identified and documented for further investigation.

No source staging records were modified or deleted during this validation phase.

The next phase will focus on investigating the identified issues and developing appropriate data cleaning and transformation rules before loading the data into the data warehouse.