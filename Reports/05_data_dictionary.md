# Data Dictionary

**Project:** Olist Data Engineering  
**Layer:** Clean Layer  
**Database:** SQL Server  
**Report:** 05 – Data Dictionary

## 1. Overview

This document describes the structure and purpose of the tables and columns available in the Olist Clean Layer.

The Data Dictionary provides a reference for developers, data engineers, and analysts who need to understand the datasets before using them for analytical processing or Data Warehouse development.

## 2. Customers Table

**Table:** `clean.customers`

**Description:** Contains customer identification and location information.

| Column | Description |
|---|---|
| customer_id | Unique identifier assigned to a customer record |
| customer_unique_id | Identifier representing the customer across records |
| customer_zip_code_prefix | Customer ZIP code prefix |
| customer_city | Customer city |
| customer_state | Customer state |

## 3. Sellers Table

**Table:** `clean.seller`

**Description:** Contains seller identification and location information.

| Column | Description |
|---|---|
| seller_id | Unique seller identifier |
| seller_zip_code_prefix | Seller ZIP code prefix |
| seller_city | Seller city |
| seller_state | Seller state |

## 4. Products Table

**Table:** `clean.products`

**Description:** Contains product details and physical attributes.

| Column | Description |
|---|---|
| product_id | Unique product identifier |
| product_category_name | Original product category name |
| product_name_lenght | Length of the product name |
| product_description_lenght | Length of the product description |
| product_photos_qty | Number of product photos |
| product_weight_g | Product weight in grams |
| product_length_cm | Product length in centimeters |
| product_height_cm | Product height in centimeters |
| product_width_cm | Product width in centimeters |

## 5. Product Category Translation Table

**Table:** `clean.product_category_name_translation`

**Description:** Maps Portuguese product category names to their English translations.

| Column | Description |
|---|---|
| product_category_name | Product category name in Portuguese |
| product_category_name_english | English translation of the product category |

## 6. Geolocations Table

**Table:** `clean.geolocations`

**Description:** Contains geographic coordinates and location information associated with ZIP code prefixes.

| Column | Description |
|---|---|
| geolocation_zip_code_prefix | Geographic ZIP code prefix |
| geolocation_lat | Geographic latitude |
| geolocation_lng | Geographic longitude |
| geolocation_city | Geographic city |
| geolocation_state | Geographic state |

## 7. Deduplicated Geolocations Table

**Table:** `clean.geolocations_deduplicated`

**Description:** Contains distinct geolocation records created from the original clean geolocation dataset.

The table uses the same five columns as `clean.geolocations`:

| Column | Description |
|---|---|
| geolocation_zip_code_prefix | Geographic ZIP code prefix |
| geolocation_lat | Geographic latitude |
| geolocation_lng | Geographic longitude |
| geolocation_city | Geographic city |
| geolocation_state | Geographic state |

## 8. Orders Table

**Table:** `clean.orders`

**Description:** Contains order information, status, and order lifecycle timestamps.

| Column | Description |
|---|---|
| order_id | Unique order identifier |
| customer_id | Customer associated with the order |
| order_status | Current or recorded order status |
| order_purchase_timestamp | Date and time when the order was placed |
| order_approved_at | Date and time when the order was approved |
| order_delivered_carrier_date | Date and time when the order was handed to the carrier |
| order_delivered_customer_date | Date and time when the order was delivered to the customer |
| order_estimated_delivery_date | Estimated delivery date |

## 9. Order Items Table

**Table:** `clean.order_items`

**Description:** Contains individual product items associated with customer orders.

| Column | Description |
|---|---|
| order_id | Associated order identifier |
| order_item_id | Item sequence number within an order |
| product_id | Product identifier |
| seller_id | Seller identifier |
| shipping_limit_date | Deadline for the seller to hand the item to the carrier |
| price | Item price |
| freight_value | Freight or shipping cost associated with the item |

## 10. Order Payments Table

**Table:** `clean.order_payments`

**Description:** Contains payment transaction details associated with orders.

| Column | Description |
|---|---|
| order_id | Associated order identifier |
| payment_sequential | Sequential number of the payment within an order |
| payment_type | Payment method |
| payment_installments | Number of payment installments |
| payment_value | Payment amount |

## 11. Order Reviews Table

**Table:** `clean.order_reviews`

**Description:** Contains customer feedback and review information associated with orders.

| Column | Description |
|---|---|
| review_id | Review identifier |
| order_id | Associated order identifier |
| review_score | Customer review score |
| review_comment_title | Review comment title |
| review_comment_message | Review comment message |
| review_creation_date | Date when the review was created |
| review_answer_timestamp | Date and time when the review was answered |

## 12. Data Dictionary Notes

- Column names follow the source dataset naming conventions.
- The Clean Layer standardizes data types while retaining the original business meaning of columns.
- ZIP code prefixes are stored as text to preserve leading zeros.
- Geographic coordinates use decimal numeric types.
- Timestamp columns represent order and review lifecycle events.
- NULL values may be present in optional attributes.
- The deduplicated geolocation table is a separate derived dataset.

## 13. Conclusion

This Data Dictionary provides a reference for the tables and columns available in the Olist Clean Layer.

It establishes a common understanding of the dataset structure and supports future development of fact tables, dimension tables, and analytical models in the Data Warehouse layer.

---

**Report Status:** Prepared  
**Previous Report:** 04_data_reconciliation_report.md  
**Documentation Status:** All Five Reports Prepared