/*
Project: Olist Data Engineering
Database: OlistDataWarehouse
Script: 04_Cleaning_And_Transformation.sql

Purpose:
Convert staging data into properly typed and standardized
clean tables, followed by data cleaning and business transformations.

Source Layer:
dbo (Staging Tables)

Target Layer:
clean (Cleaned Tables)

Planned Activities:
1. Create clean schema.
2. Convert source columns to appropriate data types.
3. Handle data quality issues.
4. Standardize data.
5. Apply business transformation rules.
6. Validate the cleaned tables.

Important:
Original staging tables will remain unchanged.
*/

use OlistDataWarehouse;
select COLUMN_NAME, DATA_TYPE 
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'stg_customers';

select COLUMN_NAME, DATA_TYPE,CHARACTER_MAXIMUM_LENGTH,IS_NULLABLE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'stg_customers'
order by ORDINAL_POSITION;

SELECT
    MAX(LEN(customer_id)) AS MaxCustomerId,
    MAX(LEN(customer_unique_id)) AS MaxUniqueId,
    MAX(LEN(customer_zip_code_prefix)) AS MaxZipLength,
    MAX(LEN(customer_city)) AS MaxCityLength,
    MAX(LEN(LTRIM(RTRIM(customer_state)))) AS MaxStateLength
FROM dbo.stg_customers;

--create clean schema if it does not exist
if NOT EXISTS(
SELECT 1
FROM SYS.schemas
WHERE name = 'clean'
)begin
	exec('create schema clean')
end;

USE OlistDataWarehouse;
GO

-- Verify schema
SELECT SCHEMA_ID('clean') AS CleanSchemaID;
GO

-- Create table
CREATE TABLE clean.customers
(
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(5),
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);
GO

INSERT INTO clean.customers
(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    -- Your SELECT expressions
	TRIM(c.customer_id),
	TRIM(c.customer_unique_id),
	TRIM(c.customer_zip_code_prefix),
	TRIM(c.customer_city),
	TRIM(c.customer_state)
FROM dbo.stg_customers as c;

SELECT COUNT(*) AS MissingCustomers
FROM dbo.stg_customers AS c
LEFT JOIN clean.customers AS cc
    ON c.customer_id = cc.customer_id
WHERE cc.customer_id IS NULL;

select *
from stg_customers as c
left join clean.customers as cc on c.customer_id = cc.customer_id
where cc.customer_id is null or
	  cc.customer_unique_id is null or
	  cc.customer_zip_code_prefix is null or
	  cc.customer_city is null or
	  cc.customer_state is null

SELECT *
FROM dbo.stg_customers
EXCEPT
SELECT *
FROM clean.customers;

SELECT *
FROM clean.customers
EXCEPT
SELECT *
FROM dbo.stg_customers;

select COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH,IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='stg_sellers';

select max(LEN(TRIM(s.seller_id))) as lenSid,
	   max(LEN(TRIM(s.seller_zip_code_prefix))) as len_zipCode,
	   max(LEN(TRIM(s.seller_state))) as len_state,
	   max(LEN(TRIM(s.seller_city)))as len_city
from stg_sellers as s

create table clean.seller(
seller_id varchar(50) primary key,
seller_zip_code_prefix varchar(5),
seller_state char(2),
seller_city varchar(100)
)

insert into clean.seller(
seller_id,
seller_zip_code_prefix,
seller_state,
seller_city
)
select TRIM(s.seller_id),TRIM(s.seller_zip_code_prefix),TRIM(s.seller_state),TRIM(s.seller_city) 
from stg_sellers as s;

select count(*)as totalRows
from clean.seller;

select *
from stg_sellers as s
left join clean.seller as cs on s.seller_id = cs.seller_id
where cs.seller_id is null

select *
from stg_sellers as s
left join clean.seller as cs on s.seller_id = cs.seller_id
where cs.seller_id is null or
	  cs.seller_zip_code_prefix is null or
	  cs.seller_state is null or
	  cs.seller_city is null 

select seller_id,seller_zip_code_prefix,seller_state ,seller_city from stg_sellers
except 
select seller_id,seller_zip_code_prefix,seller_state ,seller_city from clean.seller

select seller_id,seller_zip_code_prefix,seller_state ,seller_city from clean.seller
except 
select seller_id,seller_zip_code_prefix,seller_state ,seller_city from  stg_sellers

select count(*) as totalRows, 
	   sum(case when seller_id is null then 1 else 0 end) as nullInId,
	   sum(case when seller_zip_code_prefix is null then 1 else 0 end) as nullInZip,
	   sum(case when seller_state is null then 1 else 0 end) as nullInState,
	   sum(case when seller_city is null then 1 else 0 end) as nullInCity
from clean.seller;

select COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'stg_products';

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN  product_name_lenght IS NOT NULL THEN 1 ELSE 0 END) AS invalid_name_length,
    SUM(CASE WHEN product_description_lenght IS NOT NULL THEN 1 ELSE 0 END) AS invalid_description_length,
    SUM(CASE WHEN  product_photos_qty IS NOT NULL THEN 1 ELSE 0 END) AS invalid_photos_qty,
    SUM(CASE WHEN  product_weight_g IS NOT NULL THEN 1 ELSE 0 END) AS invalid_weight,
    SUM(CASE WHEN  product_length_cm IS NOT NULL THEN 1 ELSE 0 END) AS invalid_length,
    SUM(CASE WHEN  product_height_cm IS NOT NULL THEN 1 ELSE 0 END) AS invalid_height,
    SUM(CASE WHEN  product_width_cm IS NOT NULL THEN 1 ELSE 0 END) AS invalid_width
FROM dbo.stg_products;

SELECT *
FROM dbo.stg_products
WHERE product_name_lenght IS NULL
   OR product_description_lenght IS NULL
   OR product_photos_qty IS NULL
   OR product_weight_g IS NULL
   OR product_length_cm IS NULL
   OR product_height_cm IS NULL
   OR product_width_cm IS NULL;

SELECT
    p.product_id,
    COUNT(oi.product_id) AS total_order_items
FROM dbo.stg_products AS p
LEFT JOIN dbo.stg_order_items AS oi
    ON p.product_id = oi.product_id
WHERE p.product_weight_g IS NULL
   OR p.product_length_cm IS NULL
   OR p.product_height_cm IS NULL
   OR p.product_width_cm IS NULL
GROUP BY p.product_id;

SELECT
    order_id,
    order_item_id,
    product_id,
    price,
    freight_value
FROM dbo.stg_order_items
WHERE product_id = '5eb564652db742ff8f28759cd8d2652a'
ORDER BY order_id;

SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_id) AS distinct_products
FROM dbo.stg_products
WHERE product_category_name IS NULL;

create table clean.products(
product_id varchar(50) primary key,
product_category_name varchar(100)null,
product_name_lenght int null,
product_description_lenght int null,
product_photos_qty int null,
product_weight_g int null,
product_length_cm int null,
product_height_cm int null,
product_width_cm int null
)
 select * from clean.products

 select * from stg_products

insert into clean.products(
product_id ,
product_category_name,
product_name_lenght,
product_description_lenght,
product_photos_qty,
product_weight_g,
product_length_cm,
product_height_cm,
product_width_cm
)
select TRIM(product_id),TRIM(product_category_name),
	TRY_CONVERT(int,TRIM(product_name_lenght)),
	TRY_CONVERT(int,TRIM(product_description_lenght)),
	TRY_CONVERT(int,TRIM(product_photos_qty)),
	TRY_CONVERT(int,TRIM(product_weight_g)),
	TRY_CONVERT(int,TRIM(product_length_cm)),
	TRY_CONVERT(int,TRIM(product_height_cm)),
	TRY_CONVERT(int,TRIM(product_width_cm))
from stg_products

SELECT COUNT(*) AS total_products
FROM clean.products;

SELECT
    TRIM(product_id),
    TRIM(product_category_name),
    TRY_CONVERT(INT, TRIM(product_name_lenght)),
    TRY_CONVERT(INT, TRIM(product_description_lenght)),
    TRY_CONVERT(INT, TRIM(product_photos_qty)),
    TRY_CONVERT(INT, TRIM(product_weight_g)),
    TRY_CONVERT(INT, TRIM(product_length_cm)),
    TRY_CONVERT(INT, TRIM(product_height_cm)),
    TRY_CONVERT(INT, TRIM(product_width_cm))
FROM dbo.stg_products

EXCEPT

SELECT *
FROM clean.products;

SELECT *
FROM clean.products
EXCEPT
SELECT
    TRIM(product_id),
    TRIM(product_category_name),
    TRY_CONVERT(INT, TRIM(product_name_lenght)),
    TRY_CONVERT(INT, TRIM(product_description_lenght)),
    TRY_CONVERT(INT, TRIM(product_photos_qty)),
    TRY_CONVERT(INT, TRIM(product_weight_g)),
    TRY_CONVERT(INT, TRIM(product_length_cm)),
    TRY_CONVERT(INT, TRIM(product_height_cm)),
    TRY_CONVERT(INT, TRIM(product_width_cm))
FROM dbo.stg_products;


select count(*)as TotalRows,
	   sum(case when product_id is null then 1 else 0 end) as idNull,
	   sum(case when product_category_name is null then 1 else 0 end) as CatNameNull,
	   sum(case when product_name_lenght is null then 1 else 0 end) as nameLengthNull,
	   sum(case when product_description_lenght is null then 1 else 0 end) as decriptionLength_Null,
	   sum(case when product_photos_qty is null then 1 else 0 end) as photoQ_Null,
	   sum(case when product_weight_g is null then 1 else 0 end) as weight_Null,
	   sum(case when product_length_cm is null then 1 else 0 end) as length_Null,
	   sum(case when product_height_cm is null then 1 else 0 end) as height_Null,
	   sum(case when product_width_cm is null then 1 else 0 end) as width_Null
from clean.products;


SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'stg_order_payments'
ORDER BY ORDINAL_POSITION;

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN TRY_CONVERT(INT, TRIM(payment_sequential)) IS NULL
             AND payment_sequential IS NOT NULL THEN 1 ELSE 0 END) AS invalid_sequential,
    SUM(CASE WHEN TRY_CONVERT(INT, TRIM(payment_installments)) IS NULL
             AND payment_installments IS NOT NULL THEN 1 ELSE 0 END) AS invalid_installments,
    SUM(CASE WHEN TRY_CONVERT(DECIMAL(10,2), TRIM(payment_value)) IS NULL
             AND payment_value IS NOT NULL THEN 1 ELSE 0 END) AS invalid_payment_value
FROM dbo.stg_order_payments;

select count(*) as totalRows,
	sum(case when order_id is null then 1 else 0 end) as nullId,
	sum(case when payment_sequential is null then 1 else 0 end) as nullpayment_sequential,
	sum(case when payment_type is null then 1 else 0 end) as null_payment_type,
	sum(case when payment_installments is null then 1 else 0 end) as null_payment_installments,
	sum(case when payment_value is null then 1 else 0 end) as null_payment_value
from stg_order_payments;

CREATE TABLE clean.order_payments(
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS total
FROM dbo.stg_order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

select * from clean.order_payments

insert into clean.order_payments(
 order_id,
 payment_sequential,
 payment_type,
 payment_installments,
 payment_value
)
select TRIM(s.order_id),TRY_CONVERT(int,s.payment_sequential),TRIM(s.payment_type),TRY_CONVERT(int,s.payment_installments),
		TRY_CONVERT(decimal(10,2),s.payment_value)
from stg_order_payments as s

SELECT COUNT(*) AS total_payments
FROM clean.order_payments;

SELECT
    TRIM(order_id) AS order_id,
    TRY_CONVERT(INT, TRIM(payment_sequential)) AS payment_sequential,
    TRIM(payment_type) AS payment_type,
    TRY_CONVERT(INT, TRIM(payment_installments)) AS payment_installments,
    TRY_CONVERT(DECIMAL(10,2), TRIM(payment_value)) AS payment_value
FROM dbo.stg_order_payments



SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM clean.order_payments
EXCEPT
SELECT
    TRIM(order_id) AS order_id,
    TRY_CONVERT(INT, TRIM(payment_sequential)) AS payment_sequential,
    TRIM(payment_type) AS payment_type,
    TRY_CONVERT(INT, TRIM(payment_installments)) AS payment_installments,
    TRY_CONVERT(DECIMAL(10,2), TRIM(payment_value)) AS payment_value
FROM dbo.stg_order_payments;

SELECT
    COUNT(*) AS totalRows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS nullOrderId,
    SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS nullSequential,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS nullPaymentType,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS nullInstallments,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS nullPaymentValue
FROM clean.order_payments;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'stg_order_items'
ORDER BY ORDINAL_POSITION;

SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN TRY_CONVERT(INT, TRIM(order_item_id)) IS NULL
             AND order_item_id IS NOT NULL THEN 1 ELSE 0 END) AS invalid_item_id,

    SUM(CASE WHEN TRY_CONVERT(DATETIME2, TRIM(shipping_limit_date)) IS NULL
             AND shipping_limit_date IS NOT NULL THEN 1 ELSE 0 END) AS invalid_shipping_date,

    SUM(CASE WHEN TRY_CONVERT(DECIMAL(10,2), TRIM(price)) IS NULL
             AND price IS NOT NULL THEN 1 ELSE 0 END) AS invalid_price,

    SUM(CASE WHEN TRY_CONVERT(DECIMAL(10,2), TRIM(freight_value)) IS NULL
             AND freight_value IS NOT NULL THEN 1 ELSE 0 END) AS invalid_freight
FROM dbo.stg_order_items;

SELECT
    COUNT(*) AS totalRows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS nullOrderId,
    SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS nullSequential,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS nullPaymentType,
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS nullInstallments,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS nullPaymentValue,
	SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS nullPaymentValue,
	SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS nullPaymentValue
FROM stg_order_items;

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS total
FROM dbo.stg_order_items
GROUP BY
    order_id,
    order_item_id
HAVING COUNT(*) > 1;

create table clean.order_items(
order_id varchar(50), 
order_item_id int, 
product_id varchar(50),
seller_id varchar(50),
shipping_limit_date DATETIME2,
price decimal(10,2),
freight_value decimal(10,2),
primary key(order_id,order_item_id)
)

insert into clean.order_items(
order_id, 
order_item_id, 
product_id,
seller_id,
shipping_limit_date,
price,
freight_value
)
select TRIM(o.order_id),
		TRY_CONVERT(int,TRIM(o.order_item_id)),
		TRIM(o.product_id),
		TRIM(o.seller_id),
		TRY_CONVERT(datetime2,TRIM(o.shipping_limit_date)),
		TRY_CONVERT(decimal(10,2),TRIM(o.price)),
		TRY_CONVERT(decimal(10,2),TRIM(o.freight_value))
from stg_order_items as o

SELECT COUNT(*) AS total_order_items
FROM clean.order_items;

SELECT
    TRIM(order_id) AS order_id,
    TRY_CONVERT(INT, TRIM(order_item_id)) AS order_item_id,
    TRIM(product_id) AS product_id,
    TRIM(seller_id) AS seller_id,
    TRY_CONVERT(DATETIME2, TRIM(shipping_limit_date)) AS shipping_limit_date,
    TRY_CONVERT(DECIMAL(10,2), TRIM(price)) AS price,
    TRY_CONVERT(DECIMAL(10,2), TRIM(freight_value)) AS freight_value
FROM dbo.stg_order_items

EXCEPT

SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM clean.order_items;

SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM clean.order_items
except
SELECT
    TRIM(order_id) AS order_id,
    TRY_CONVERT(INT, TRIM(order_item_id)) AS order_item_id,
    TRIM(product_id) AS product_id,
    TRIM(seller_id) AS seller_id,
    TRY_CONVERT(DATETIME2, TRIM(shipping_limit_date)) AS shipping_limit_date,
    TRY_CONVERT(DECIMAL(10,2), TRIM(price)) AS price,
    TRY_CONVERT(DECIMAL(10,2), TRIM(freight_value)) AS freight_value
FROM dbo.stg_order_items

EXEC sp_help 'dbo.stg_orders';

create table clean.orders(
order_id varchar(50) primary key,
customer_id varchar(50),
order_status varchar(30),
order_purchase_timestamp DATETIME2,
order_approved_at DATETIME2,
order_delivered_carrier_date DATETIME2,
order_delivered_customer_date DATETIME2,
order_estimated_delivery_date DATETIME2
)

insert into clean.orders(
order_id ,
customer_id,
order_status,
order_purchase_timestamp ,
order_approved_at ,
order_delivered_carrier_date ,
order_delivered_customer_date ,
order_estimated_delivery_date
)
select TRIM(o.order_id),
		TRIM(o.customer_id),
		TRIM(o.order_status),
		TRY_CONVERT(datetime2,TRIM(o.order_purchase_timestamp)),
		TRY_CONVERT(datetime2,TRIM(o.order_approved_at)),
		TRY_CONVERT(datetime2,TRIM(o.order_delivered_carrier_date)),
		TRY_CONVERT(datetime2,TRIM(o.order_delivered_customer_date)),
		TRY_CONVERT(datetime2,TRIM(o.order_estimated_delivery_date))
from stg_orders as o

SELECT COUNT(*) AS total_orders
FROM clean.orders;

SELECT
    TRIM(order_id),
    TRIM(customer_id),
    TRIM(order_status),
    TRY_CONVERT(DATETIME2, TRIM(order_purchase_timestamp)),
    TRY_CONVERT(DATETIME2, TRIM(order_approved_at)),
    TRY_CONVERT(DATETIME2, TRIM(order_delivered_carrier_date)),
    TRY_CONVERT(DATETIME2, TRIM(order_delivered_customer_date)),
    TRY_CONVERT(DATETIME2, TRIM(order_estimated_delivery_date))
FROM dbo.stg_orders

EXCEPT

SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM clean.orders;


SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM clean.orders
EXCEPT
SELECT
    TRIM(order_id),
    TRIM(customer_id),
    TRIM(order_status),
    TRY_CONVERT(DATETIME2, TRIM(order_purchase_timestamp)),
    TRY_CONVERT(DATETIME2, TRIM(order_approved_at)),
    TRY_CONVERT(DATETIME2, TRIM(order_delivered_carrier_date)),
    TRY_CONVERT(DATETIME2, TRIM(order_delivered_customer_date)),
    TRY_CONVERT(DATETIME2, TRIM(order_estimated_delivery_date))
FROM dbo.stg_orders;

exec sp_help 'stg_order_reviews'
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE
        WHEN TRY_CONVERT(INT, TRIM(review_score)) IS NULL
             AND review_score IS NOT NULL
        THEN 1 ELSE 0
    END) AS invalid_review_score,

    SUM(CASE
        WHEN TRY_CONVERT(DATETIME2, TRIM(review_creation_date)) IS NULL
             AND review_creation_date IS NOT NULL
        THEN 1 ELSE 0
    END) AS invalid_creation_date,

    SUM(CASE
        WHEN TRY_CONVERT(DATETIME2, TRIM(review_answer_timestamp)) IS NULL
             AND review_answer_timestamp IS NOT NULL
        THEN 1 ELSE 0
    END) AS invalid_answer_timestamp

FROM dbo.stg_order_reviews;


SELECT
    order_id,
    COUNT(*) AS review_count
FROM dbo.stg_order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
    review_id,
    COUNT(*) AS review_count
FROM dbo.stg_order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

SELECT
    review_id,
    order_id,
    COUNT(*) AS duplicate_count
FROM dbo.stg_order_reviews
GROUP BY
    review_id,
    order_id
HAVING COUNT(*) > 1;

CREATE TABLE clean.order_reviews (
    review_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) NOT NULL,
    review_score INT,
    review_comment_title VARCHAR(200),
    review_comment_message VARCHAR(500),
    review_creation_date DATETIME2,
    review_answer_timestamp DATETIME2,

    CONSTRAINT PK_clean_order_reviews
        PRIMARY KEY (review_id, order_id)
);

insert into clean.order_reviews(
order_id,
review_id ,
    review_score ,
    review_comment_title,
    review_comment_message ,
    review_creation_date ,
    review_answer_timestamp 
)
select trim (v.order_id),
		TRIM(v.review_id),
		TRY_CONVERT(int,TRIM(v.review_score)),
		TRIM(v.review_comment_title),
		TRIM(v.review_comment_message),
		TRY_CONVERT(DATETIME2,TRIM(v.review_creation_date)),
		TRY_CONVERT(DATETIME2,TRIM(v.review_answer_timestamp))
from stg_order_reviews v


SELECT COUNT(*) AS total_clean_reviews
FROM clean.order_reviews;

-- Records in staging but not in clean
SELECT
    order_id,
    review_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM clean.order_reviews

EXCEPT

SELECT
    TRIM(v.order_id),
    TRIM(v.review_id),
    TRY_CONVERT(INT, TRIM(v.review_score)),
    TRIM(v.review_comment_title),
    TRIM(v.review_comment_message),
    TRY_CONVERT(DATETIME2, TRIM(v.review_creation_date)),
    TRY_CONVERT(DATETIME2, TRIM(v.review_answer_timestamp))
FROM dbo.stg_order_reviews AS v;

SELECT
    TRIM(v.order_id),
    TRIM(v.review_id),
    TRY_CONVERT(INT, TRIM(v.review_score)),
    TRIM(v.review_comment_title),
    TRIM(v.review_comment_message),
    TRY_CONVERT(DATETIME2, TRIM(v.review_creation_date)),
    TRY_CONVERT(DATETIME2, TRIM(v.review_answer_timestamp))
FROM dbo.stg_order_reviews AS v
EXCEPT
SELECT
    order_id,
    review_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM clean.order_reviews;

EXEC sp_help 'dbo.stg_geolocations';
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(10,7), TRIM(geolocation_lat)) IS NULL
             AND geolocation_lat IS NOT NULL
        THEN 1 ELSE 0
    END) AS invalid_latitude,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(10,7), TRIM(geolocation_lng)) IS NULL
             AND geolocation_lng IS NOT NULL
        THEN 1 ELSE 0
    END) AS invalid_longitude

FROM dbo.stg_geolocations;

CREATE TABLE clean.geolocations (
    geolocation_zip_code_prefix VARCHAR(5),
    geolocation_lat DECIMAL(10,7),
    geolocation_lng DECIMAL(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

INSERT INTO clean.geolocations (
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
)
SELECT
    TRIM(geolocation_zip_code_prefix),
    TRY_CONVERT(DECIMAL(10,7), TRIM(geolocation_lat)),
    TRY_CONVERT(DECIMAL(10,7), TRIM(geolocation_lng)),
    TRIM(geolocation_city),
    TRIM(geolocation_state)
FROM dbo.stg_geolocations;

SELECT COUNT(*) AS total_clean_geolocations
FROM clean.geolocations;
SELECT
    TRIM(geolocation_zip_code_prefix),
    TRY_CONVERT(DECIMAL(10,7), TRIM(geolocation_lat)),
    TRY_CONVERT(DECIMAL(10,7), TRIM(geolocation_lng)),
    TRIM(geolocation_city),
    TRIM(geolocation_state)
FROM dbo.stg_geolocations

EXCEPT

SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM clean.geolocations;

SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM clean.geolocations

EXCEPT

SELECT
    TRIM(geolocation_zip_code_prefix),
    TRY_CONVERT(DECIMAL(10,7), TRIM(geolocation_lat)),
    TRY_CONVERT(DECIMAL(10,7), TRIM(geolocation_lng)),
    TRIM(geolocation_city),
    TRIM(geolocation_state)
FROM dbo.stg_geolocations;

SELECT
    geolocation_zip_code_prefix,
    COUNT(*) AS record_count
FROM clean.geolocations
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS duplicate_count
FROM clean.geolocations
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT(
        geolocation_zip_code_prefix, '|',
        geolocation_lat, '|',
        geolocation_lng, '|',
        geolocation_city, '|',
        geolocation_state
    )) AS distinct_records
FROM clean.geolocations;

SELECT
    SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip,
    SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END) AS null_lat,
    SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END) AS null_lng,
    SUM(CASE WHEN geolocation_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN geolocation_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM clean.geolocations;

CREATE TABLE clean.geolocations_deduplicated
(
    geolocation_zip_code_prefix VARCHAR(5) NOT NULL,
    geolocation_lat DECIMAL(10,7) NOT NULL,
    geolocation_lng DECIMAL(10,7) NOT NULL,
    geolocation_city VARCHAR(100) NOT NULL,
    geolocation_state CHAR(2) NOT NULL,

    CONSTRAINT PK_geolocations_deduplicated
        PRIMARY KEY
        (
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state
        )
);

INSERT INTO clean.geolocations_deduplicated
(
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
)
SELECT DISTINCT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM clean.geolocations;

SELECT
    COUNT(*) AS total_deduplicated_records
FROM clean.geolocations_deduplicated;

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_codes
FROM clean.geolocations_deduplicated;

SELECT COUNT(*) AS unmatched_records
FROM clean.geolocations_deduplicated d
WHERE NOT EXISTS (
    SELECT 1
    FROM clean.geolocations g
    WHERE g.geolocation_zip_code_prefix = d.geolocation_zip_code_prefix
      AND g.geolocation_lat = d.geolocation_lat
      AND g.geolocation_lng = d.geolocation_lng
      AND g.geolocation_city = d.geolocation_city
      AND g.geolocation_state = d.geolocation_state
);

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_category_name) AS unique_portuguese_categories,
    COUNT(DISTINCT product_category_name_english) AS unique_english_categories
FROM dbo.stg_product_category_name_translation;

SELECT
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_portuguese,
    SUM(CASE WHEN product_category_name_english IS NULL THEN 1 ELSE 0 END) AS null_english,

    SUM(CASE WHEN LTRIM(RTRIM(product_category_name)) = '' THEN 1 ELSE 0 END) AS empty_portuguese,
    SUM(CASE WHEN LTRIM(RTRIM(product_category_name_english)) = '' THEN 1 ELSE 0 END) AS empty_english
FROM dbo.stg_product_category_name_translation;

CREATE TABLE clean.product_category_name_translation
(
    product_category_name VARCHAR(100) NOT NULL,
    product_category_name_english VARCHAR(100) NOT NULL,

    CONSTRAINT PK_product_category_name_translation
        PRIMARY KEY (product_category_name)
);

INSERT INTO clean.product_category_name_translation
(
    product_category_name,
    product_category_name_english
)
SELECT
    LTRIM(RTRIM(product_category_name)),
    LTRIM(RTRIM(product_category_name_english))
FROM dbo.stg_product_category_name_translation;

SELECT COUNT(*) AS total_records
FROM clean.product_category_name_translation;


-- Check records missing from clean table
SELECT
    product_category_name,
    product_category_name_english
FROM dbo.stg_product_category_name_translation

EXCEPT

SELECT
    product_category_name,
    product_category_name_english
FROM clean.product_category_name_translation;

-- Check extra records in clean table
SELECT
    product_category_name,
    product_category_name_english
FROM clean.product_category_name_translation

EXCEPT

SELECT
    product_category_name,
    product_category_name_english
FROM dbo.stg_product_category_name_translation;
---------------------

SELECT
    customer_city,
    COUNT(*) AS customer_count
FROM clean.customers
GROUP BY customer_city
ORDER BY customer_city;

SELECT
    COUNT(*) AS total_records,

    SUM(CASE
        WHEN customer_city IS NULL THEN 1
        ELSE 0
    END) AS null_cities,

    SUM(CASE
        WHEN LTRIM(RTRIM(customer_city)) = '' THEN 1
        ELSE 0
    END) AS empty_cities

FROM clean.customers;
SELECT
    customer_city,
    COUNT(*) AS affected_records
FROM clean.customers
WHERE customer_city <> LTRIM(RTRIM(customer_city))
GROUP BY customer_city
ORDER BY affected_records DESC;

SELECT
    customer_state,
    COUNT(DISTINCT customer_city) AS unique_cities,
    COUNT(*) AS customer_count
FROM clean.customers
GROUP BY customer_state
ORDER BY customer_state;

SELECT
    customer_state,
    COUNT(*) AS customer_count
FROM clean.customers
WHERE customer_state NOT IN (
    'AC', 'AL', 'AM', 'AP', 'BA', 'CE', 'DF',
    'ES', 'GO', 'MA', 'MG', 'MS', 'MT', 'PA',
    'PB', 'PE', 'PI', 'PR', 'RJ', 'RN', 'RO',
    'RR', 'RS', 'SC', 'SE', 'SP', 'TO'
)
GROUP BY customer_state;

SELECT
    customer_city,
    COUNT(DISTINCT customer_state) AS state_count,
    STRING_AGG(CAST(customer_state AS VARCHAR(MAX)), ', ') AS states
FROM clean.customers
GROUP BY customer_city
HAVING COUNT(DISTINCT customer_state) > 1
ORDER BY state_count DESC, customer_city;

WITH distinct_city_states AS
(
    SELECT DISTINCT
        customer_city,
        customer_state
    FROM clean.customers
)
SELECT
    customer_city,
    COUNT(*) AS state_count,
    STRING_AGG(
        CAST(customer_state AS VARCHAR(MAX)),
        ', '
    ) AS states
FROM distinct_city_states
GROUP BY customer_city
HAVING COUNT(*) > 1
ORDER BY state_count DESC, customer_city;

use OlistDataWarehouse;
SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT c.customer_zip_code_prefix) AS unique_customer_zip_codes,
    COUNT(DISTINCT g.geolocation_zip_code_prefix) AS matched_zip_codes
FROM clean.customers c
LEFT JOIN clean.geolocations_deduplicated g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix;

	SELECT DISTINCT
    c.customer_zip_code_prefix
FROM clean.customers c
LEFT JOIN clean.geolocations_deduplicated g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL
ORDER BY c.customer_zip_code_prefix;

WITH unmatched_zip_codes AS
(
    SELECT DISTINCT
        c.customer_zip_code_prefix
    FROM clean.customers c
    LEFT JOIN clean.geolocations_deduplicated g
        ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
    WHERE g.geolocation_zip_code_prefix IS NULL
)
SELECT
    c.customer_zip_code_prefix,
    COUNT(*) AS affected_customers,
    COUNT(DISTINCT c.customer_city) AS unique_cities,
    COUNT(DISTINCT c.customer_state) AS unique_states
FROM clean.customers c
INNER JOIN unmatched_zip_codes u
    ON c.customer_zip_code_prefix = u.customer_zip_code_prefix
GROUP BY c.customer_zip_code_prefix
ORDER BY affected_customers DESC;

WITH unmatched_zip_codes AS
(
    SELECT DISTINCT
        c.customer_zip_code_prefix
    FROM clean.customers c
    LEFT JOIN clean.geolocations_deduplicated g
        ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
    WHERE g.geolocation_zip_code_prefix IS NULL
)
SELECT
    c.customer_state,
    COUNT(*) AS affected_customers,
    COUNT(DISTINCT c.customer_zip_code_prefix) AS unmatched_zip_codes
FROM clean.customers c
INNER JOIN unmatched_zip_codes u
    ON c.customer_zip_code_prefix = u.customer_zip_code_prefix
GROUP BY c.customer_state
ORDER BY affected_customers DESC;

SELECT
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state,
    COUNT(*) AS customer_count
FROM clean.customers c
LEFT JOIN clean.geolocations_deduplicated g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL
    AND c.customer_state = 'DF'
GROUP BY
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state
ORDER BY customer_count DESC;

WITH unmatched_zip_codes AS
(
    SELECT DISTINCT
        c.customer_zip_code_prefix
    FROM clean.customers c
    LEFT JOIN clean.geolocations_deduplicated g
        ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
    WHERE g.geolocation_zip_code_prefix IS NULL
)
SELECT
    c.customer_state,
    c.customer_city,
    COUNT(DISTINCT c.customer_zip_code_prefix) AS unmatched_zip_codes,
    COUNT(*) AS affected_customers
FROM clean.customers c
INNER JOIN unmatched_zip_codes u
    ON c.customer_zip_code_prefix = u.customer_zip_code_prefix
WHERE c.customer_state <> 'DF'
GROUP BY
    c.customer_state,
    c.customer_city
ORDER BY
    affected_customers DESC;

SELECT
    customer_city,
    COUNT(*) AS total_customers
FROM clean.customers
WHERE customer_state = 'SP'
GROUP BY customer_city
HAVING COUNT(*) > 100
ORDER BY total_customers DESC;

SELECT
    customer_unique_id,
    COUNT(*) AS total_records
FROM clean.customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY total_records DESC;

--------------------

select seller_id,count(*)as totalIds
from clean.seller
group by seller_id
having count(*)>1;

select count(*)as totalRows,sum(case when seller_id is null then 1 else 0 end)as idNull,
		sum(case when trim(seller_id)= '' then 1 else 0 end)as emplyId
from clean.seller

select count(*)as totalRows,sum(case when seller_zip_code_prefix is null then 1 else 0 end)as idNull,
		sum(case when trim(seller_zip_code_prefix)= '' then 1 else 0 end)as emplyId,
		sum( case when (seller_zip_code_prefix is not null and len(seller_zip_code_prefix)=5 and TRY_CONVERT(int,seller_zip_code_prefix)is not null) then 1 else 0 end)as validLenthCode 
from clean.seller

select count(*)as toatalRows,count(distinct seller_state)as uniqueStates,
		sum(case when seller_state is null then 1 else 0 end)as nullStates,
		sum(case when trim(seller_state) = '' then 1 else 0 end ) as emptyStates,
		sum(case when (seller_state is not null and len(seller_state) = 2) then 1 else 0 end)as vailedlenth
from clean.seller

select seller_state 
from clean.seller
where seller_state not in ('AC', 'AL', 'AM', 'AP', 'BA', 'CE', 'DF',
    'ES', 'GO', 'MA', 'MG', 'MS', 'MT', 'PA',
    'PB', 'PE', 'PI', 'PR', 'RJ', 'RN', 'RO',
    'RR', 'RS', 'SC', 'SE', 'SP', 'TO');

select count(*)as totalSellers,count(distinct seller_city)as totalcites
from clean.seller

select count(*)as toatalRows,count(distinct seller_city)as uniqueCites,
		sum(case when seller_city is null then 1 else 0 end)as nullCites,
		sum(case when trim(seller_city) = '' then 1 else 0 end ) as emptyCites
from clean.seller

select count(seller_city)as Cites
from clean.seller
where seller_city <> TRIM(seller_city)


select seller_city, count(distinct seller_state)as totalState
from clean.seller
group by seller_city
having count(distinct seller_state)>1

use OlistDataWarehouse;
select seller_id, count(seller_city)as numCites, count(seller_state)as numStats
from clean.seller
group by seller_id
having count(seller_city)>1 or count(seller_state)>1;

select seller_city,seller_state,count(*)as combine
from clean.seller
group by seller_city,seller_state
having count(*)>1;

SELECT
    seller_id,
    seller_city,
    seller_state
FROM clean.seller
WHERE seller_city IN (
    'santa barbara d''oeste',
    'santa barbara d´oeste',
    'sao paulo',
    'sao paulo - sp',
    'sp'
)
ORDER BY seller_city;

SELECT
    seller_id,
    seller_city,
    seller_state
FROM dbo.stg_sellers
WHERE seller_city IN (
    'santa barbara d''oeste',
    'santa barbara d´oeste',
    'sao paulo',
    'sao paulo - sp',
    'sp'
)
ORDER BY seller_city;
use OlistDataWarehouse;
SELECT
    seller_city,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city LIKE '%santa barbara%'
GROUP BY seller_city
ORDER BY seller_city;

SELECT
    seller_city,
    COUNT(*) AS total_sellers
FROM dbo.stg_sellers
WHERE seller_city LIKE '%santa barbara%'
GROUP BY seller_city
ORDER BY seller_city;

SELECT
    seller_city AS old_city,
    'santa barbara d''oeste' AS new_city,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city IN (
    'santa barbara d oeste',
    'santa barbara d''oeste',
    N'santa barbara d´oeste'
)
GROUP BY seller_city;

UPDATE clean.seller
SET seller_city = 'santa barbara d''oeste'
WHERE seller_city IN (
    'santa barbara d oeste',
    N'santa barbara d´oeste'
);

SELECT DISTINCT seller_city
FROM clean.seller
ORDER BY seller_city;

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city IN (
    'belo horizont',
    'balenario camboriu',
    'cascavael',
    'floranopolis',
    'garulhos',
    'juzeiro do norte',
    'mogi das cruses',
    'ribeirao pretp',
    'riberao preto',
    'robeirao preto',
    'sando andre',
    'sao bernardo do capo',
    'sao jose do rio pret',
    'sao jose dos pinhas',
    'sao paluo',
    'sao paulop',
    'sao pauo',
    'tabao da serra'
)
GROUP BY seller_city, seller_state
ORDER BY seller_city, seller_state;

SELECT
    seller_city AS old_city,
    seller_state,
    'balneario camboriu' AS proposed_city
FROM clean.seller
WHERE seller_city = 'balenario camboriu';

UPDATE clean.seller
SET seller_city = 'balneario camboriu'
WHERE seller_city = 'balenario camboriu'
  AND seller_state = 'SC';

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city = 'belo horizont'
GROUP BY seller_city, seller_state;

UPDATE clean.seller
SET seller_city = 'belo horizonte'
WHERE seller_city = 'belo horizont'
  AND seller_state = 'MG';

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city = 'cascavael'
GROUP BY seller_city, seller_state;

UPDATE clean.seller
SET seller_city = 'cascavel'
WHERE seller_city = 'cascavael'
  AND seller_state = 'PR';

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city = 'floranopolis'
GROUP BY seller_city, seller_state;

UPDATE clean.seller
SET seller_city = 'florianopolis'
WHERE seller_city = 'floranopolis'
  AND seller_state = 'SC';

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city = 'garulhos'
GROUP BY seller_city, seller_state;

UPDATE clean.seller
SET seller_city = 'guarulhos'
WHERE seller_city = 'garulhos'
  AND seller_state = 'SP';

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city = 'juzeiro do norte'
GROUP BY seller_city, seller_state;

UPDATE clean.seller
SET seller_city = 'juazeiro do norte'
WHERE seller_city = 'juzeiro do norte'
  AND seller_state = 'CE';

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city = 'mogi das cruses'
GROUP BY seller_city, seller_state;

UPDATE clean.seller
SET seller_city = 'mogi das cruzes'
WHERE seller_city = 'mogi das cruses'
  AND seller_state = 'SP';

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city = 'ribeirao pretp'
GROUP BY seller_city, seller_state;

UPDATE clean.seller
SET seller_city = 'ribeirao preto'
WHERE seller_city = 'ribeirao pretp'
  AND seller_state = 'SP';

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city = 'riberao preto'
GROUP BY seller_city, seller_state;

UPDATE clean.seller
SET seller_city = 'ribeirao preto'
WHERE seller_city = 'riberao preto'
  AND seller_state = 'SP';

  SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city IN (
    'ribeirao pretp',
    'riberao preto',
    'robeirao preto',
    'sando andre',
    'sao bernardo do capo',
    'sao jose do rio pret',
    'sao jose dos pinhas',
    'sao paluo',
    'sao paulop',
    'sao pauo',
    'tabao da serra'
)
GROUP BY
    seller_city,
    seller_state
ORDER BY
    seller_city,
    seller_state;

UPDATE clean.seller
SET seller_city =
    CASE
        WHEN seller_city = 'robeirao preto'
            THEN 'ribeirao preto'
        WHEN seller_city = 'sando andre'
            THEN 'santo andre'
        WHEN seller_city = 'sao bernardo do capo'
            THEN 'sao bernardo do campo'
        WHEN seller_city = 'sao jose do rio pret'
            THEN 'sao jose do rio preto'
        WHEN seller_city = 'sao jose dos pinhas'
            THEN 'sao jose dos pinhais'
        WHEN seller_city IN ('sao paluo', 'sao paulop', 'sao pauo')
            THEN 'sao paulo'
        WHEN seller_city = 'tabao da serra'
            THEN 'taboao da serra'
    END
WHERE
    (seller_city = 'robeirao preto' AND seller_state = 'SP')
    OR (seller_city = 'sando andre' AND seller_state = 'SP')
    OR (seller_city = 'sao bernardo do capo' AND seller_state = 'SP')
    OR (seller_city = 'sao jose do rio pret' AND seller_state = 'SP')
    OR (seller_city = 'sao jose dos pinhas' AND seller_state = 'PR')
    OR (seller_city IN ('sao paluo', 'sao paulop', 'sao pauo')
        AND seller_state = 'SP')
    OR (seller_city = 'tabao da serra' AND seller_state = 'SP');

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city IN (
    'aguas claras df',
    'andira-pr',
    'angra dos reis rj',
    'auriflama/sp',
    'barbacena/ minas gerais',
    'brasilia df',
    'carapicuiba / sao paulo',
    'cariacica / es',
    'jacarei / sao paulo',
    'lages - sc',
    'maua/sao paulo',
    'mogi das cruzes / sp',
    'novo hamburgo, rio grande do sul, brasil',
    'pinhais/pr',
    'rio de janeiro / rio de janeiro',
    'rio de janeiro, rio de janeiro, brasil',
    'sao paulo - sp',
    'sao paulo / sao paulo',
    'sao paulo sp',
    'santo andre/sao paulo',
    'sao sebastiao da grama/sp',
    'sbc',
    'sbc/sp',
    'sp / sp',
    'lages - sc'
)
GROUP BY
    seller_city,
    seller_state
ORDER BY
    seller_city,
    seller_state;

SELECT
    seller_city AS old_city,
    seller_state,
    CASE
        WHEN seller_city = 'andira-pr'
            THEN 'andira'
        WHEN seller_city = 'angra dos reis rj'
            THEN 'angra dos reis'
        WHEN seller_city = 'aurifilma/sp'
            THEN 'aurifilma'
        WHEN seller_city = 'barbacena/ minas gerais'
            THEN 'barbacena'
        WHEN seller_city = 'brasilia df'
            THEN 'brasilia'
        WHEN seller_city = 'carapicuiba / sao paulo'
            THEN 'carapicuiba'
        WHEN seller_city = 'cariacica / es'
            THEN 'cariacica'
        WHEN seller_city = 'jacarei / sao paulo'
            THEN 'jacarei'
        WHEN seller_city = 'lages - sc'
            THEN 'lages'
        WHEN seller_city = 'maua/sao paulo'
            THEN 'maua'
        WHEN seller_city = 'mogi das cruzes / sp'
            THEN 'mogi das cruzes'
        WHEN seller_city = 'novo hamburgo, rio grande do sul, brasil'
            THEN 'novo hamburgo'
        WHEN seller_city = 'pinhais/pr'
            THEN 'pinhais'
        WHEN seller_city IN (
            'rio de janeiro / rio de janeiro',
            'rio de janeiro, rio de janeiro, brasil'
        )
            THEN 'rio de janeiro'
        WHEN seller_city = 'santo andre/sao paulo'
            THEN 'santo andre'
        WHEN seller_city IN (
            'sao paulo - sp',
            'sao paulo / sao paulo',
            'sao paulo sp'
        )
            THEN 'sao paulo'
        WHEN seller_city = 'sao sebastiao da grama/sp'
            THEN 'sao sebastiao da grama'
    END AS proposed_city,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city IN (
    'andira-pr',
    'angra dos reis rj',
    'aurifilma/sp',
    'barbacena/ minas gerais',
    'brasilia df',
    'carapicuiba / sao paulo',
    'cariacica / es',
    'jacarei / sao paulo',
    'lages - sc',
    'maua/sao paulo',
    'mogi das cruzes / sp',
    'novo hamburgo, rio grande do sul, brasil',
    'pinhais/pr',
    'rio de janeiro / rio de janeiro',
    'rio de janeiro, rio de janeiro, brasil',
    'santo andre/sao paulo',
    'sao paulo - sp',
    'sao paulo / sao paulo',
    'sao paulo sp',
    'sao sebastiao da grama/sp'
)
GROUP BY seller_city, seller_state
ORDER BY seller_city;

UPDATE clean.seller
SET seller_city =
    CASE
        WHEN seller_city = 'andira-pr'
            THEN 'andira'
        WHEN seller_city = 'angra dos reis rj'
            THEN 'angra dos reis'
        WHEN seller_city = 'barbacena/ minas gerais'
            THEN 'barbacena'
        WHEN seller_city = 'brasilia df'
            THEN 'brasilia'
        WHEN seller_city = 'carapicuiba / sao paulo'
            THEN 'carapicuiba'
        WHEN seller_city = 'cariacica / es'
            THEN 'cariacica'
        WHEN seller_city = 'jacarei / sao paulo'
            THEN 'jacarei'
        WHEN seller_city = 'lages - sc'
            THEN 'lages'
        WHEN seller_city = 'maua/sao paulo'
            THEN 'maua'
        WHEN seller_city = 'mogi das cruzes / sp'
            THEN 'mogi das cruzes'
        WHEN seller_city = 'novo hamburgo, rio grande do sul, brasil'
            THEN 'novo hamburgo'
        WHEN seller_city = 'pinhais/pr'
            THEN 'pinhais'
        WHEN seller_city IN (
            'rio de janeiro / rio de janeiro',
            'rio de janeiro, rio de janeiro, brasil'
        )
            THEN 'rio de janeiro'
        WHEN seller_city = 'santo andre/sao paulo'
            THEN 'santo andre'
        WHEN seller_city IN (
            'sao paulo - sp',
            'sao paulo / sao paulo',
            'sao paulo sp'
        )
            THEN 'sao paulo'
        WHEN seller_city = 'sao sebastiao da grama/sp'
            THEN 'sao sebastiao da grama'
    END
WHERE seller_city IN (
    'andira-pr',
    'angra dos reis rj',
    'barbacena/ minas gerais',
    'brasilia df',
    'carapicuiba / sao paulo',
    'cariacica / es',
    'jacarei / sao paulo',
    'lages - sc',
    'maua/sao paulo',
    'mogi das cruzes / sp',
    'novo hamburgo, rio grande do sul, brasil',
    'pinhais/pr',
    'rio de janeiro / rio de janeiro',
    'rio de janeiro, rio de janeiro, brasil',
    'santo andre/sao paulo',
    'sao paulo - sp',
    'sao paulo / sao paulo',
    'sao paulo sp',
    'sao sebastiao da grama/sp'
);
SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city IN (
    'andira-pr',
    'angra dos reis rj',
    'barbacena/ minas gerais',
    'brasilia df',
    'carapicuiba / sao paulo',
    'cariacica / es',
    'jacarei / sao paulo',
    'lages - sc',
    'maua/sao paulo',
    'mogi das cruzes / sp',
    'novo hamburgo, rio grande do sul, brasil',
    'pinhais/pr',
    'rio de janeiro / rio de janeiro',
    'rio de janeiro, rio de janeiro, brasil',
    'santo andre/sao paulo',
    'sao paulo - sp',
    'sao paulo / sao paulo',
    'sao paulo sp',
    'sao sebastiao da grama/sp'
)
GROUP BY seller_city, seller_state;

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city IN (
    'aguas claras df',
    'sbc',
    'sbc/sp',
    'sp / sp',
    'aurifilma/sp'
)
GROUP BY seller_city, seller_state
ORDER BY seller_city;

SELECT DISTINCT
    s.seller_city,
    s.seller_state,
    s.seller_zip_code_prefix,
    g.geolocation_city,
    g.geolocation_state
FROM clean.seller AS s
LEFT JOIN clean.geolocations_deduplicated AS g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE s.seller_city IN (
    'aguas claras df',
    'sbc',
    'sbc/sp',
    'sp / sp'
)
ORDER BY
    s.seller_city,
    g.geolocation_city;

SELECT
    s.seller_id,
    s.seller_city AS clean_city,
    s.seller_state AS clean_state,
    s.seller_zip_code_prefix AS clean_zip,
    st.seller_city AS staging_city,
    st.seller_state AS staging_state,
    st.seller_zip_code_prefix AS staging_zip
FROM clean.seller AS s
INNER JOIN dbo.stg_sellers AS st
    ON s.seller_id = st.seller_id
WHERE s.seller_city IN (
    'aguas claras df',
    'sbc',
    'sbc/sp',
    'sp / sp'
)
ORDER BY s.seller_city;

UPDATE clean.seller
SET seller_city =
    CASE
        WHEN seller_city IN ('sbc', 'sbc/sp')
            THEN 'sao bernardo do campo'
        WHEN seller_city = 'sp / sp'
            THEN 'sao paulo'
    END
WHERE seller_city IN ('sbc', 'sbc/sp', 'sp / sp')
  AND seller_state = 'SP';

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city IN (
    'bahia',
    'minas gerais',
    'parana',
    'santa catarina',
    'centro',
    'california',
    'tocantins',
    'vendas@creditparts.com.br',
    '04482255'
)
GROUP BY
    seller_city,
    seller_state
ORDER BY seller_city;

SELECT DISTINCT
    s.seller_city,
    s.seller_state,
    s.seller_zip_code_prefix,
    g.geolocation_city,
    g.geolocation_state
FROM clean.seller AS s
LEFT JOIN clean.geolocations_deduplicated AS g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE s.seller_city IN (
    '04482255',
    'bahia',
    'california',
    'centro',
    'minas gerais',
    'parana',
    'santa catarina',
    'tocantins',
    'vendas@creditparts.com.br'
)
ORDER BY s.seller_city, g.geolocation_city;

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    s.seller_zip_code_prefix
FROM clean.seller AS s
WHERE s.seller_city IN (
    '04482255',
    'bahia',
    'california',
    'centro',
    'minas gerais',
    'parana',
    'santa catarina',
    'tocantins',
    'vendas@creditparts.com.br'
)
ORDER BY s.seller_city;

SELECT
    s.seller_city,
    s.seller_state,
    s.seller_zip_code_prefix,
    COUNT(DISTINCT g.geolocation_city) AS geolocation_cities,
    COUNT(DISTINCT g.geolocation_state) AS geolocation_states
FROM clean.seller AS s
LEFT JOIN clean.geolocations_deduplicated AS g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE s.seller_city IN (
    '04482255',
    'bahia',
    'california',
    'centro',
    'minas gerais',
    'parana',
    'santa catarina',
    'tocantins',
    'vendas@creditparts.com.br'
)
GROUP BY
    s.seller_city,
    s.seller_state,
    s.seller_zip_code_prefix
ORDER BY s.seller_city;

SELECT
    seller_id,
    seller_city,
    seller_state,
    seller_zip_code_prefix
FROM dbo.stg_sellers
WHERE seller_id IN (
    'ceb7b4fb9401cd378de7886317ad1b47',
    '4221a7df464f1fe2955934e30ff3a5a1',
    '52f976b17ea7f2f087f56dcc419328f6',
    'd5c530f4884a75ae0dba9c148718d278',
    '1703bc09972dab9782e7a9194943b69f',
    'b906dd0e57f282c7089171b6ed07982e',
    'ba8e85df286308fe68a2ce83a8f8b2d6',
    'c8771b1a10bb99bb34d3c459c5cffb53',
    '4b5f66b7adcf57f1ecc0d3c07dd6b177'
);

SELECT
    seller_city AS old_city,
    seller_state,
    seller_zip_code_prefix,
    CASE
        WHEN seller_city = '04482255'
            THEN 'rio de janeiro'
        WHEN seller_city = 'bahia'
            THEN 'paulo afonso'
        WHEN seller_city = 'centro'
            THEN 'para de minas'
        WHEN seller_city = 'minas gerais'
            THEN 'campo do meio'
        WHEN seller_city = 'parana'
            THEN 'maringa'
        WHEN seller_city = 'santa catarina'
            THEN 'palhoca'
        WHEN seller_city = 'vendas@creditparts.com.br'
            THEN 'maringa'
    END AS proposed_city
FROM clean.seller
WHERE seller_city IN (
    '04482255',
    'bahia',
    'centro',
    'minas gerais',
    'parana',
    'santa catarina',
    'vendas@creditparts.com.br'
);

UPDATE clean.seller
SET seller_city =
    CASE
        WHEN seller_city = 'minas gerais'
            THEN 'campo do meio'
        WHEN seller_city = 'bahia'
            THEN 'paulo afonso'
        WHEN seller_city = 'vendas@creditparts.com.br'
            THEN 'maringa'
        WHEN seller_city = 'parana'
            THEN 'maringa'
        WHEN seller_city = 'santa catarina'
            THEN 'palhoca'
        WHEN seller_city = '04482255'
            THEN 'rio de janeiro'
        WHEN seller_city = 'centro'
            THEN 'para de minas'
    END
WHERE seller_city IN (
    'minas gerais',
    'bahia',
    'vendas@creditparts.com.br',
    'parana',
    'santa catarina',
    '04482255',
    'centro'
);

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city IN (
    'santa barbara d oeste',
    'santa barbara d´oeste',
    'belo horizont',
    'cascavael',
    'floranopolis',
    'garulhos',
    'juzeiro do norte',
    'mogi das cruses',
    'ribeirao pretp',
    'riberao preto',
    'robeirao preto',
    'sando andre',
    'sao bernardo do capo',
    'sao jose do rio pret',
    'sao jose dos pinhas',
    'sao paluo',
    'sao paulop',
    'sao pauo',
    'tabao da serra',
    'sbc',
    'sbc/sp',
    'sp / sp',
    'aguas claras df',
    '04482255',
    'bahia',
    'centro',
    'minas gerais',
    'parana',
    'santa catarina',
    'vendas@creditparts.com.br'
)
GROUP BY seller_city, seller_state
ORDER BY seller_city;

SELECT
    seller_city,
    seller_state,
    seller_zip_code_prefix,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city IN (
    'tocantins',
    'california',
    'aurifilima/sp'
)
GROUP BY
    seller_city,
    seller_state,
    seller_zip_code_prefix;

SELECT
    seller_city,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city LIKE '%  %'
GROUP BY seller_city
ORDER BY seller_city;

UPDATE clean.seller
SET seller_city = REPLACE(seller_city, '  ', ' ')
WHERE seller_city LIKE '%  %';

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE
       seller_city LIKE '%[0-9]%'
    OR seller_city LIKE '%@%'
    OR seller_city LIKE '%/%'
    OR seller_city LIKE '%,%'
    OR seller_city LIKE '%-%'
    OR seller_city LIKE '%  %'
GROUP BY
    seller_city,
    seller_state
ORDER BY seller_city;

SELECT DISTINCT
    s.seller_city,
    s.seller_state,
    s.seller_zip_code_prefix,
    g.geolocation_city,
    g.geolocation_state
FROM clean.seller AS s
LEFT JOIN clean.geolocations_deduplicated AS g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE s.seller_city IN (
    'auriflama/sp',
    'ribeirao preto / sao paulo'
)
ORDER BY s.seller_city;

UPDATE clean.seller
SET seller_city =
    CASE
        WHEN seller_city = 'auriflama/sp'
            THEN 'auriflama'
        WHEN seller_city = 'ribeirao preto / sao paulo'
            THEN 'ribeirao preto'
    END
WHERE seller_city IN (
    'auriflama/sp',
    'ribeirao preto / sao paulo'
)
AND seller_state = 'SP';

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE seller_city IN (
    'auriflama/sp',
    'ribeirao preto / sao paulo'
)
GROUP BY seller_city, seller_state;

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM clean.seller
WHERE
       seller_city LIKE '%[0-9]%'
    OR seller_city LIKE '%@%'
    OR seller_city LIKE '%/%'
    OR seller_city LIKE '%,%'
    OR seller_city LIKE '%-%'
    OR seller_city LIKE '%  %'
GROUP BY
    seller_city,
    seller_state
ORDER BY seller_city;

SELECT
    COUNT(*) AS total_sellers,
    COUNT(DISTINCT seller_id) AS unique_sellers
FROM clean.seller;

----------------------------------

SELECT
    product_id,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM clean.products
WHERE
       product_weight_g <= 0
    OR product_length_cm <= 0
    OR product_height_cm <= 0
    OR product_width_cm <= 0;

	SELECT
    c.product_id,
    c.product_weight_g AS clean_weight,
    s.product_weight_g AS staging_weight
FROM clean.products AS c
INNER JOIN dbo.stg_products AS s
    ON c.product_id = s.product_id
WHERE c.product_weight_g = 0;

SELECT
    product_id,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM clean.products
WHERE
       product_weight_g < 0
    OR product_length_cm < 0
    OR product_height_cm < 0
    OR product_width_cm < 0;

	SELECT
    MAX(product_weight_g) AS max_weight_g,
    MAX(product_length_cm) AS max_length_cm,
    MAX(product_height_cm) AS max_height_cm,
    MAX(product_width_cm) AS max_width_cm
FROM clean.products;

SELECT TOP 10
    product_id,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM clean.products
ORDER BY product_weight_g DESC;

SELECT
    COUNT(*) AS total_products,
    SUM(CASE
        WHEN product_weight_g = 30000 THEN 1
        ELSE 0
    END) AS products_30kg
FROM clean.products;

SELECT
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    COUNT(*) AS total_products
FROM clean.products
WHERE product_weight_g = 30000
GROUP BY
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
ORDER BY total_products DESC;

SELECT
    product_category_name,
    COUNT(*) AS total_products
FROM clean.products
WHERE product_weight_g = 30000
GROUP BY product_category_name
ORDER BY total_products DESC;

SELECT
    COUNT(*) AS total_products,
    SUM(CASE
        WHEN product_weight_g IS NULL THEN 1
        ELSE 0
    END) AS null_weight,
    SUM(CASE
        WHEN product_weight_g = 0 THEN 1
        ELSE 0
    END) AS zero_weight,
    SUM(CASE
        WHEN product_weight_g > 0 THEN 1
        ELSE 0
    END) AS positive_weight
FROM clean.products;

SELECT
    COUNT(*) AS total_products,

    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_length,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS null_height,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS null_width,

    SUM(CASE WHEN product_length_cm = 0 THEN 1 ELSE 0 END) AS zero_length,
    SUM(CASE WHEN product_height_cm = 0 THEN 1 ELSE 0 END) AS zero_height,
    SUM(CASE WHEN product_width_cm = 0 THEN 1 ELSE 0 END) AS zero_width
FROM clean.products;

SELECT
    product_id,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM clean.products
WHERE
    product_length_cm IS NULL
    OR product_height_cm IS NULL
    OR product_width_cm IS NULL;

	SELECT
    c.product_id,
    c.product_weight_g AS clean_weight,
    s.product_weight_g AS staging_weight,
    c.product_length_cm AS clean_length,
    s.product_length_cm AS staging_length,
    c.product_height_cm AS clean_height,
    s.product_height_cm AS staging_height,
    c.product_width_cm AS clean_width,
    s.product_width_cm AS staging_width
FROM clean.products AS c
INNER JOIN dbo.stg_products AS s
    ON c.product_id = s.product_id
WHERE c.product_id IN (
    '09ff539a621711667c43eba6a3bd8466',
    '5eb564652db742ff8f28759cd8d2652a'
);

SELECT *
FROM clean.products
WHERE product_id IN (
    '09ff539a621711667c43eba6a3bd8466',
    '5eb564652db742ff8f28759cd8d2652a'
);

SELECT
    COUNT(*) AS TotalProducts,
    SUM(CASE
        WHEN product_weight_g IS NULL
         AND product_length_cm IS NOT NULL
        THEN 1 ELSE 0
    END) AS WeightMissingButLengthExists,
    SUM(CASE
        WHEN product_weight_g IS NOT NULL
         AND product_length_cm IS NULL
        THEN 1 ELSE 0
    END) AS LengthMissingButWeightExists
FROM clean.products;

SELECT
    COUNT(*) AS TotalProducts,
    SUM(CASE
        WHEN product_length_cm IS NOT NULL
         AND product_height_cm IS NOT NULL
         AND product_width_cm IS NOT NULL
        THEN 1 ELSE 0
    END) AS AllDimensionsAvailable,
    SUM(CASE
        WHEN product_length_cm IS NULL
          OR product_height_cm IS NULL
          OR product_width_cm IS NULL
        THEN 1 ELSE 0
    END) AS IncompleteDimensions
FROM clean.products;

SELECT
    COUNT(*) AS TotalProducts,
    SUM(CASE
        WHEN product_category_name IS NULL THEN 1
        ELSE 0
    END) AS NullCategories,
    SUM(CASE
        WHEN product_category_name = '' THEN 1
        ELSE 0
    END) AS EmptyCategories,
    SUM(CASE
        WHEN product_category_name <> LTRIM(RTRIM(product_category_name))
        THEN 1 ELSE 0
    END) AS CategoriesWithExtraSpaces
FROM clean.products;

SELECT
    product_category_name,
    COUNT(*) AS TotalProducts
FROM clean.products
WHERE product_category_name IS NOT NULL
GROUP BY product_category_name
ORDER BY TotalProducts DESC;

SELECT
    p.product_category_name,
    COUNT(*) AS TotalProducts
FROM clean.products AS p
LEFT JOIN clean.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY TotalProducts DESC;

SELECT
    COUNT(*) AS TotalMappings,
    COUNT(DISTINCT product_category_name) AS UniquePortuguese,
    COUNT(DISTINCT product_category_name_english) AS UniqueEnglish,
    SUM(CASE
        WHEN product_category_name_english IS NULL
          OR LTRIM(RTRIM(product_category_name_english)) = ''
        THEN 1 ELSE 0
    END) AS MissingEnglish
FROM clean.product_category_name_translation;

SELECT
    product_category_name,
    COUNT(*) AS TotalProducts
FROM clean.products
WHERE product_category_name IS NOT NULL
  AND product_category_name NOT LIKE '%[a-z]%'
GROUP BY product_category_name;

use OlistDataWarehouse;

SELECT
    COUNT(*) AS TotalItems,

    SUM(CASE
        WHEN o.order_id IS NULL THEN 1
        ELSE 0
    END) AS MissingOrders,

    SUM(CASE
        WHEN p.product_id IS NULL THEN 1
        ELSE 0
    END) AS MissingProducts,

    SUM(CASE
        WHEN s.seller_id IS NULL THEN 1
        ELSE 0
    END) AS MissingSellers

FROM clean.order_items AS oi

LEFT JOIN clean.orders AS o
    ON oi.order_id = o.order_id

LEFT JOIN clean.products AS p
    ON oi.product_id = p.product_id

LEFT JOIN clean.seller AS s
    ON oi.seller_id = s.seller_id;

SELECT
    COUNT(*) AS TotalItems,

    SUM(CASE WHEN price < 0 THEN 1 ELSE 0 END) AS NegativePrice,
    SUM(CASE WHEN price = 0 THEN 1 ELSE 0 END) AS ZeroPrice,

    SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS NegativeFreight,
    SUM(CASE WHEN freight_value = 0 THEN 1 ELSE 0 END) AS ZeroFreight

FROM clean.order_items;

SELECT
    price,
    COUNT(*) AS TotalItems
FROM clean.order_items
WHERE freight_value = 0
GROUP BY price
ORDER BY TotalItems DESC;

SELECT
    COUNT(*) AS TotalItems,
    SUM(CASE
        WHEN oi.shipping_limit_date < o.order_purchase_timestamp
        THEN 1 ELSE 0
    END) AS DeadlineBeforePurchase
FROM clean.order_items AS oi
INNER JOIN clean.orders AS o
    ON oi.order_id = o.order_id;

SELECT
    COUNT(*) AS TotalItems,
    SUM(CASE
        WHEN o.order_delivered_carrier_date IS NOT NULL
         AND oi.shipping_limit_date < o.order_delivered_carrier_date
        THEN 1 ELSE 0
    END) AS ShippedAfterDeadline,
    SUM(CASE
        WHEN o.order_delivered_carrier_date IS NULL
        THEN 1 ELSE 0
    END) AS NotShippedOrNoCarrierDate
FROM clean.order_items AS oi
INNER JOIN clean.orders AS o
    ON oi.order_id = o.order_id;

	SELECT
    o.order_status,
    COUNT(*) AS LateItems
FROM clean.order_items AS oi
INNER JOIN clean.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_delivered_carrier_date IS NOT NULL
  AND oi.shipping_limit_date < o.order_delivered_carrier_date
GROUP BY o.order_status
ORDER BY LateItems DESC;

SELECT
    oi.order_id,
    oi.order_item_id,
    oi.shipping_limit_date,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date
FROM clean.order_items AS oi
INNER JOIN clean.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'canceled'
  AND oi.shipping_limit_date < o.order_delivered_carrier_date;

SELECT
    o.order_id,
    o.order_status,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    r.review_id,
    r.review_score
FROM clean.orders AS o
LEFT JOIN clean.order_reviews AS r
    ON o.order_id = r.order_id
WHERE o.order_status = 'canceled'
  AND o.order_delivered_carrier_date IS NOT NULL
  AND EXISTS (
      SELECT 1
      FROM clean.order_items AS oi
      WHERE oi.order_id = o.order_id
        AND oi.shipping_limit_date < o.order_delivered_carrier_date
  )
ORDER BY o.order_id;

SELECT
    r.order_id,
    r.review_score,
    r.review_comment_title,
    r.review_comment_message
FROM clean.order_reviews AS r
WHERE r.order_id IN (
    '1def7af24cb7182497acfd953f6dd88b',
    '2c0032906c603dcc21cd954828fa77d0',
    '4472eca3b65b1dca5e0d59c0e4e0c6bc',
    '65d1e226dfaeb8cdc42f665422522d14',
    '854f8cb8dacdc3abc4cce7a7df6fcc1f',
    '8beb59392e21af5eb9547ae1a9938d06',
    '9ec3685b1f21c7dfff4f656392b186dd',
    'fe9fae71b4fa7d05f1934adc54391f8d'
);
SELECT
    COUNT(*) AS LateItems,
    COUNT(DISTINCT oi.order_id) AS LateOrders
FROM clean.order_items AS oi
INNER JOIN clean.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_delivered_carrier_date IS NOT NULL
  AND oi.shipping_limit_date < o.order_delivered_carrier_date;

  SELECT
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    COUNT(DISTINCT CASE
        WHEN o.order_delivered_carrier_date IS NOT NULL
         AND oi.shipping_limit_date < o.order_delivered_carrier_date
        THEN o.order_id
    END) AS LateOrders,
    CAST(
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_carrier_date IS NOT NULL
             AND oi.shipping_limit_date < o.order_delivered_carrier_date
            THEN o.order_id
        END) * 100.0
        / COUNT(DISTINCT o.order_id)
        AS DECIMAL(5,2)
    ) AS LateOrderPercentage
FROM clean.order_items AS oi
INNER JOIN clean.orders AS o
    ON oi.order_id = o.order_id;

	SELECT
    order_id,
    COUNT(*) AS TotalItems,
    COUNT(DISTINCT shipping_limit_date) AS DifferentDeadlines
FROM clean.order_items
GROUP BY order_id
HAVING COUNT(DISTINCT shipping_limit_date) > 1
ORDER BY DifferentDeadlines DESC;

SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date
FROM clean.order_items
WHERE order_id = '0a77b770428bccbea7f9dbf8aec5d6ae'
ORDER BY shipping_limit_date;

SELECT
    order_id,
    seller_id,
    COUNT(*) AS TotalItems,
    COUNT(DISTINCT shipping_limit_date) AS DifferentDeadlines
FROM clean.order_items
GROUP BY
    order_id,
    seller_id
HAVING COUNT(DISTINCT shipping_limit_date) > 1
ORDER BY DifferentDeadlines DESC;


SELECT TOP 10
    order_id,
    COUNT(*) AS TotalItems,
    MIN(order_item_id) AS FirstItemNumber,
    MAX(order_item_id) AS LastItemNumber
FROM clean.order_items
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY TotalItems DESC;

SELECT
    order_id,
    COUNT(*) AS TotalItems,
    MIN(order_item_id) AS FirstItem,
    MAX(order_item_id) AS LastItem
FROM clean.order_items
GROUP BY order_id
HAVING COUNT(*) <> MAX(order_item_id);

SELECT
    COUNT(*) AS TotalPayments,
    SUM(CASE
        WHEN o.order_id IS NULL THEN 1
        ELSE 0
    END) AS MissingOrders
FROM clean.order_payments AS p
LEFT JOIN clean.orders AS o
    ON p.order_id = o.order_id;

	SELECT
    SUM(CASE WHEN payment_value < 0 THEN 1 ELSE 0 END) AS NegativePayments,
    SUM(CASE WHEN payment_installments < 0 THEN 1 ELSE 0 END) AS NegativeInstallments
FROM clean.order_payments;

SELECT
    payment_type,
    COUNT(*) AS TotalRecords
FROM clean.order_payments
GROUP BY payment_type
ORDER BY TotalRecords DESC;

SELECT
    payment_type,
    MIN(payment_installments) AS MinInstallments,
    MAX(payment_installments) AS MaxInstallments
FROM clean.order_payments
GROUP BY payment_type;

SELECT *
FROM clean.order_payments
WHERE payment_type = 'credit_card'
  AND payment_installments = 0;

  SELECT *
FROM dbo.stg_order_payments
WHERE order_id IN (
    '1a57108394169c0b47d8f876acc9ba2d',
    '744bade1fcf9ff3f31d860ace076d422'
);

WITH PaymentSequence AS (
    SELECT
        order_id,
        COUNT(*) AS TotalPayments,
        MIN(payment_sequential) AS MinSequence,
        MAX(payment_sequential) AS MaxSequence
    FROM clean.order_payments
    GROUP BY order_id
)
SELECT *
FROM PaymentSequence
WHERE MinSequence <> 1
   OR MaxSequence <> TotalPayments;

   WITH PaymentSequence AS (
    SELECT
        order_id,
        COUNT(*) AS TotalPayments,
        MIN(payment_sequential) AS MinSequence,
        MAX(payment_sequential) AS MaxSequence
    FROM clean.order_payments
    GROUP BY order_id
)
SELECT
    TotalPayments,
    MinSequence,
    MaxSequence,
    COUNT(*) AS AffectedOrders
FROM PaymentSequence
WHERE MinSequence <> 1
   OR MaxSequence <> TotalPayments
GROUP BY
    TotalPayments,
    MinSequence,
    MaxSequence
ORDER BY AffectedOrders DESC;

SELECT *
FROM dbo.stg_order_payments
WHERE order_id IN (
    '00ac05fe0fc047c54418098eb64e3aaa',
    '056c68d093c100017aab1f00f260705c',
    '0668d086b3ae41adde3aed3dacbc8fae'
)
ORDER BY order_id, payment_sequential;

SELECT *
FROM dbo.stg_order_payments
WHERE order_id IN (
    'a079628ac8002126e75f86b0f87332e4',
    'a4431cbd79dbddaae7988ce6091cbc3c'
)
ORDER BY order_id, payment_sequential;

WITH PaymentTotals AS (
    SELECT
        order_id,
        SUM(payment_value) AS TotalPaid
    FROM clean.order_payments
    GROUP BY order_id
),
ItemTotals AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS OrderTotal
    FROM clean.order_items
    GROUP BY order_id
)
SELECT
    p.order_id,
    p.TotalPaid,
    i.OrderTotal,
    p.TotalPaid - i.OrderTotal AS Difference
FROM PaymentTotals AS p
INNER JOIN ItemTotals AS i
    ON p.order_id = i.order_id
WHERE ABS(p.TotalPaid - i.OrderTotal) > 0.01
ORDER BY ABS(p.TotalPaid - i.OrderTotal) DESC;

SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM clean.order_payments
WHERE order_id = 'ce6d150fb29ada17d2082f4847107665';

SELECT
    order_item_id,
    price,
    freight_value,
    price + freight_value AS ItemTotal
FROM clean.order_items
WHERE order_id = 'ce6d150fb29ada17d2082f4847107665';

SELECT
    order_id,
    order_status,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM clean.orders
WHERE order_id = 'ce6d150fb29ada17d2082f4847107665';

SELECT
    order_id,
    review_score,
    review_comment_title,
    review_comment_message
FROM clean.order_reviews
WHERE order_id = 'ce6d150fb29ada17d2082f4847107665';


SELECT *
FROM dbo.stg_order_payments
WHERE order_id = 'ce6d150fb29ada17d2082f4847107665';

WITH PaymentTotals AS (
    SELECT order_id, SUM(payment_value) AS TotalPaid
    FROM clean.order_payments
    GROUP BY order_id
),
ItemTotals AS (
    SELECT order_id, SUM(price + freight_value) AS OrderTotal
    FROM clean.order_items
    GROUP BY order_id
),
Differences AS (
    SELECT
        p.order_id,
        ABS(p.TotalPaid - i.OrderTotal) AS Difference
    FROM PaymentTotals p
    INNER JOIN ItemTotals i
        ON p.order_id = i.order_id
    WHERE ABS(p.TotalPaid - i.OrderTotal) > 0.01
)
SELECT
    CASE
        WHEN Difference <= 1 THEN '0.01 - 1'
        WHEN Difference <= 5 THEN '1.01 - 5'
        WHEN Difference <= 20 THEN '5.01 - 20'
        WHEN Difference <= 50 THEN '20.01 - 50'
        WHEN Difference <= 100 THEN '50.01 - 100'
        ELSE 'Above 100'
    END AS DifferenceRange,
    COUNT(*) AS TotalOrders
FROM Differences
GROUP BY
    CASE
        WHEN Difference <= 1 THEN '0.01 - 1'
        WHEN Difference <= 5 THEN '1.01 - 5'
        WHEN Difference <= 20 THEN '5.01 - 20'
        WHEN Difference <= 50 THEN '20.01 - 50'
        WHEN Difference <= 100 THEN '50.01 - 100'
        ELSE 'Above 100'
    END
ORDER BY MIN(Difference);
------------------------------------------

select count(*) as toatlRows,
		sum(case when o.customer_id is null then 1 else 0 end) as missingIds
from clean.orders as o
left join clean.customers as c on o.customer_id = c.customer_id












