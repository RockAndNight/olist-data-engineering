SELECT TOP (1000) [customer_id]
      ,[customer_unique_id]
      ,[customer_zip_code_prefix]
      ,[customer_city]
      ,[customer_state]
  FROM [OlistDataWarehouse].[dbo].[stg_customers]

  USE OlistDataWarehouse;
GO

ALTER TABLE dbo.stg_customers
ALTER COLUMN customer_state char(4);
GO

select DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'customer_state'

select COUNT(*) as missingIds from stg_customers as stc where stc.customer_id is null


create table orders(
order_id varchar(20),
        customer_id varchar(20),
        order_status varchar(30),
        order_purchase_timestamp varchar(50),
        order_approved_at varchar(50),
        order_delivered_carrier_date varchar(50),
        order_delivered_customer_date varchar(50),
        order_estimated_delivery_date varchar(50)
)


select COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME ='stg_orders'

alter table stg_orders
alter column customer_id varchar(50)
go



select count(*) from stg_orders
use OlistDataWarehouse;
select o.order_id, count(*) as number_of_ids
from stg_orders as o
group by o.order_id
having count(*) >1

select
	o.order_id, 
	count(o.order_status) as count_status_null,
	count(o.order_purchase_timestamp)as purchase_null,
	count(o.order_approved_at) as approved_null,
	count(o.order_delivered_carrier_date) as delivered_null,
	count(o.order_delivered_customer_date) as delivered_cus_null,
	count(o.order_estimated_delivery_date)as delivery_date
from stg_orders as o
group by o.order_id,o.order_status,
	o.order_purchase_timestamp,
	order_approved_at,
	o.order_delivered_carrier_date,
	o.order_delivered_customer_date,
	o.order_estimated_delivery_date
having o.order_status is null or o.order_purchase_timestamp is null or o.order_approved_at is null or o.order_delivered_carrier_date is null or
	o.order_delivered_customer_date is null or o.order_estimated_delivery_date is null

	use OlistDataWarehouse;
	select
	o.order_id, 
	o.order_status as count_status_null,
	o.order_purchase_timestamp as purchase_null,
	o.order_approved_at as approved_null,
	o.order_delivered_carrier_date as delivered_null,
	o.order_delivered_customer_date as delivered_cus_null,
	o.order_estimated_delivery_date as delivery_date
from stg_orders as o
where o.order_status is null or o.order_purchase_timestamp is null or o.order_approved_at is null or o.order_delivered_carrier_date is null or
	o.order_delivered_customer_date is null or o.order_estimated_delivery_date is null

use OlistDataWarehouse;
create table stg_geolocations(
geolocation_zip_code_prefix varchar(50),
geolocation_lat varchar(50),
geolocation_lng varchar(50),
geolocation_city varchar(50),
geolocation_state varchar(50)
)
select * from stg_geolocations

alter table stg_geolocations
alter column geolocation_state char(4);
go

use OlistDataWarehouse;
create table stg_order_items(
order_id varchar(50),
order_item_id varchar(50),
product_id varchar(50),
seller_id varchar(50),
shipping_limit_date varchar(50),
price varchar(10),
freight_value varchar(50)
)

create table stg_order_payments(
order_id varchar(50),payment_sequential varchar(50), payment_type varchar(50), payment_installments varchar(50), payment_value varchar(50)
)

use OlistDataWarehouse;
create table stg_order_reviews(
review_id varchar(50),
order_id varchar(50),
review_score varchar(50),
review_comment_title varchar(200),
review_comment_message varchar(500),
review_creation_date varchar(50),
review_answer_timestamp varchar(50)
)

create table stg_products(
product_id varchar(50),
product_category_name varchar(100),
product_name_lenght varchar(50),
product_description_lenght varchar(150),
product_photos_qty varchar(50),
product_weight_g varchar(50),
product_length_cm varchar(50),
product_height_cm varchar(50),
product_width_cm varchar(50)
)

create table stg_sellers(
seller_id varchar(50),
seller_zip_code_prefix varchar(20),
seller_city varchar(50),
seller_state varchar(5)
)

create table stg_product_category_name_translation(
product_category_name varchar(100),
product_category_name_english varchar(100)
)

