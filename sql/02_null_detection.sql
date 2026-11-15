use OlistDataWarehouse;
select t.name as tableNames, s.name as schemasNames, SUM(p.rows) as totalRows 
from sys.tables as t
join sys.schemas as s on t.schema_id = s.schema_id
left join sys.partitions as p
on t.object_id = p.object_id and p.index_id in (0,1)
group by s.name,t.name
order by t.name;

use OlistDataWarehouse;
select count(*) as totalRows,
	sum(case when stg_c.customer_id is null then 1 else 0 end) as NullCustomerID,
	sum(case when stg_c.customer_unique_id is null then 1 else 0 end) as nullUniqeId,
	sum(case when stg_c.customer_zip_code_prefix is null then 1 else 0 end) as nullZipCode,
	SUM(case when stg_c.customer_city is null then 1 else 0 end) as nullCity,
	sum(case when stg_c.customer_state is null then 1 else 0 end) as  nullStatus
from stg_customers as stg_c

select count(*) as total_rows,
	sum(case when stg_g.geolocation_zip_code_prefix is null then 1 else 0 end) as nullZipCode,
	sum( case when stg_g.geolocation_lat is null then 1 else 0 end) as null_Lat,
	sum(case when stg_g.geolocation_lng is null then 1 else 0 end) as null_Lng,
	sum(case when stg_g.geolocation_city is null then 1 else 0 end)as nullCity,
	sum(case when stg_g.geolocation_state is null then 1 else 0 end)as nullState
from stg_geolocations as stg_g

select count(*) as total_rows,
		sum(case when stg_o.order_id is null then 1 else 0 end) as nullOrderId,
		sum(case when stg_o.customer_id is null then 1 else 0 end) as null_customerId,
		sum(case when stg_o.order_status is null then 1 else 0 end) as nullStatus,
		sum(case when stg_o.order_purchase_timestamp is null then 1 else 0 end) as null_purchase,
		sum(case when stg_o.order_approved_at is null then 1 else 0 end)as null_approveAt,
		sum(case when stg_o.order_delivered_customer_date is null then 1 else 0 end) as null_delivered_c,
		sum(case when stg_o.order_estimated_delivery_date is null then 1 else 0 end) as null_estimated
from stg_orders as stg_o
use OlistDataWarehouse;
select count(*) as total_rows,
		sum(case when stg_oi.order_id is null then 1 else 0 end) as nullOrderId,
		sum(case when stg_oi.order_item_id is null then 1 else 0 end) as null_itemId,
		sum(case when stg_oi.product_id is null then 1 else 0 end) as nullproductId,
		sum(case when stg_oi.seller_id is null then 1 else 0 end) as null_sellerID,
		sum(case when stg_oi.shipping_limit_date is null then 1 else 0 end)as null_limitDate,
		sum(case when stg_oi.price is null then 1 else 0 end) as null_price,
		sum(case when stg_oi.freight_value is null then 1 else 0 end) as null_F_value
from stg_order_items as stg_oi

use OlistDataWarehouse;
select count(*) as total_rows,
		sum(case when stg_op.order_id is null then 1 else 0 end) as nullOrderId,
		sum(case when stg_op.payment_sequential is null then 1 else 0 end) as null_paySeq,
		sum(case when stg_op.payment_type is null then 1 else 0 end) as nullPayType,
		sum(case when stg_op.payment_installments is null then 1 else 0 end) as null_payInstal,
		sum(case when stg_op.payment_value is null then 1 else 0 end)as null_PayValue
from stg_order_payments as stg_op

use OlistDataWarehouse;
select count(*) as total_rows,
		sum(case when stg_or.review_id is null then 1 else 0 end) as nullreviewId,
		sum(case when stg_or.order_id is null then 1 else 0 end) as nullOrderId,
		sum(case when stg_or.review_score is null then 1 else 0 end) as null_ReScore,
		sum(case when stg_or.review_comment_title is null then 1 else 0 end) as nullReComTi,
		sum(case when stg_or.review_comment_message is null then 1 else 0 end) as null_ReComMes,
		sum(case when stg_or.review_creation_date is null then 1 else 0 end)as null_creationDate,
		sum(case when stg_or.review_answer_timestamp is null then 1 else 0 end)as null_timestemp
from stg_order_reviews as stg_or

use OlistDataWarehouse;
select count(*) as total_rows,
		sum(case when stg_tran.product_category_name is null then 1 else 0 end) as nullNames,
		sum(case when stg_tran.product_category_name_english is null then 1 else 0 end) as nullNameEng
from [stg_product_category_name_translation] as stg_tran

use OlistDataWarehouse;
select count(*) as total_rows,
		sum(case when stg_p.product_id is null then 1 else 0 end) as nullproductId,
		sum(case when stg_p.product_category_name is null then 1 else 0 end) as nullCatName,
		sum(case when stg_p.product_name_lenght is null then 1 else 0 end) as null_NameLength,
		sum(case when stg_p.product_description_lenght is null then 1 else 0 end) as nulldiscription,
		sum(case when stg_p.product_photos_qty is null then 1 else 0 end) as null_PhoQty,
		sum(case when stg_p.product_weight_g is null then 1 else 0 end)as null_weight,
		sum(case when stg_p.product_length_cm is null then 1 else 0 end)as null_lenght,
		sum(case when stg_p.product_height_cm is null then 1 else 0 end)as null_height,
		sum(case when stg_p.product_width_cm is null then 1 else 0 end)as null_width
from stg_products as stg_p

use OlistDataWarehouse;
select count(*) as total_rows,
		sum(case when stg_s.seller_id is null then 1 else 0 end) as nullSellerId,
		sum(case when stg_s.seller_zip_code_prefix is null then 1 else 0 end) as nullZipCode,
		sum(case when stg_s.seller_city is null then 1 else 0 end) as null_NameCity,
		sum(case when stg_s.seller_state is null then 1 else 0 end) as nullState
from stg_sellers as stg_s

SELECT COUNT(*) AS ProductsWithAllFourNull
FROM dbo.stg_products
WHERE product_category_name IS NULL
  AND product_name_lenght IS NULL
  AND product_description_lenght IS NULL
  AND product_photos_qty IS NULL;


  SELECT TOP 20 *
FROM dbo.stg_products
WHERE product_category_name IS NULL
  AND product_name_lenght IS NULL
  AND product_description_lenght IS NULL
  AND product_photos_qty IS NULL;


  SELECT
    COUNT(*) AS TotalRows,
    SUM(
        CASE
            WHEN order_delivered_carrier_date IS NULL
            THEN 1 ELSE 0
        END
    ) AS NullDeliveredCarrierDate
FROM dbo.stg_orders;
--Investigate missing order dates by status
SELECT
    order_status,
    COUNT(*) AS TotalOrders,

    SUM(CASE
        WHEN order_approved_at IS NULL
        THEN 1 ELSE 0
    END) AS NullApprovedDate,

    SUM(CASE
        WHEN order_delivered_carrier_date IS NULL
        THEN 1 ELSE 0
    END) AS NullCarrierDate,

    SUM(CASE
        WHEN order_delivered_customer_date IS NULL
        THEN 1 ELSE 0
    END) AS NullCustomerDeliveryDate

FROM dbo.stg_orders
GROUP BY order_status
ORDER BY TotalOrders DESC;

--3. Investigate the delivered orders
SELECT
    order_id,
    order_status,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_purchase_timestamp
FROM dbo.stg_orders
WHERE order_status = 'delivered'
AND (
    order_approved_at IS NULL
    OR order_delivered_carrier_date IS NULL
    OR order_delivered_customer_date IS NULL
);

select c.customer_id,c.customer_city
from stg_customers as c
where c.customer_id is null and c.customer_city is null









