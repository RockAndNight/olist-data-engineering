/*
Project: Olist Data Engineering
Database: OlistDataWarehouse
Script: 03_invalid_data_detection.sql

Purpose:
Validate data quality across all nine staging tables.

Checks include:
- Invalid values and data formats
- Numeric ranges
- Date validation and chronology
- Referential integrity
- Geographic consistency
- Category translation mapping

Important:
This script is for validation only.
No source records are modified or deleted.

Detailed findings:
docs/data-quality-report.md
*/



use OlistDataWarehouse;

select distinct o.order_status
from stg_orders as o
order by o.order_status asc;

select o.order_status, count(*)as totalOrders
from stg_orders as o
group by o.order_status
order by totalOrders desc;

select *
from stg_orders as o
where o.order_status not in ('created',
'approved',
'invoiced',
'processing',
'shipped',
'delivered',
'unavailable',
'canceled' )

select o.order_status, count(*) as InvalidOrderCount
from stg_orders as o
group by o.order_status
having o.order_status not in ('created',
'approved',
'invoiced',
'processing',
'shipped',
'delivered',
'unavailable',
'canceled' )
order by InvalidOrderCount desc;

----------------------------------

select distinct o.review_score
from stg_order_reviews as o
order by o.review_score desc;

select o.review_score
from stg_order_reviews as o
where TRY_CONVERT(int,o.review_score)is null or TRY_CONVERT(int,o.review_score)<1 or TRY_CONVERT(int,o.review_score)>5

select o.review_id,o.review_comment_title,o.review_comment_message
from stg_order_reviews as o
where (o.review_comment_title is not null and TRIM(o.review_comment_title)='') or (o.review_comment_message is not null and TRIM(o.review_comment_message)='');

select o.review_id,o.review_creation_date,o.review_answer_timestamp
from stg_order_reviews as o
where (o.review_creation_date is not null and TRY_CONVERT(datetime,o.review_creation_date)is null )
	or(o.review_answer_timestamp is not null and TRY_CONVERT(datetime,o.review_answer_timestamp)is null )

select o.review_id,o.review_creation_date,o.review_answer_timestamp 
from stg_order_reviews as o
where (o.review_answer_timestamp is not null and o.review_creation_date is not null) and TRY_CONVERT(datetime,o.review_answer_timestamp)<TRY_CONVERT(datetime,o.review_creation_date) 

select count(*) as  TotalReviews,
		sum(case when TRY_CONVERT(int,o.review_score) between 1 and 5
			then 1 else 0 end)as ValidScore,
		sum(case when (TRY_CONVERT(int,o.review_score)<1 or TRY_CONVERT(int,o.review_score)>5)
			then 1 else 0 end)as InvalidScore,
		SUM(CASE
			WHEN o.review_score IS NOT NULL
				AND TRY_CONVERT(INT, o.review_score) IS NULL
			THEN 1 ELSE 0
			END) AS NonNumericScore,

		SUM(CASE
			 WHEN o.review_score IS NULL
			THEN 1 ELSE 0
			END) AS NullScore
from stg_order_reviews as o;
------------------------------------------

select count(*) as TotalOrderItems,
		sum(case when (TRY_CONVERT(decimal(10,2),oi.price)>0) then 1 else 0 end ) as TotalValiedPrices,
		sum(case when (TRY_CONVERT(decimal(10,2),oi.price)<=0) then 1 else 0 end ) as InvalidPrice,
		sum(case when (oi.price is not null and TRY_CONVERT(decimal(10,2),oi.price) is null) then 1 else 0 end ) as NonNumericPrice,
		sum(case when (oi.price IS NULL) then 1 else 0 end) as NullPrice
from stg_order_items as oi

select count(*) as TotalOrderItems,
		sum(case when (TRY_CONVERT(decimal(10,2),oi.freight_value)<0) then 1 else 0 end ) as InvalidFreight, 
		sum(case when (TRY_CONVERT(decimal(10,2),oi.freight_value)>=0 ) then 1 else 0 end ) as ValidFreight,
		sum(case when (oi.freight_value is not null and TRY_CONVERT(decimal(10,2),oi.freight_value) is null) then 1 else 0 end ) as NonNumericFreight,
		sum(case when (oi.freight_value IS NULL) then 1 else 0 end) as NullFreight
from stg_order_items as oi
------------
select count(*) as TotalProducts,
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_weight_g)<=0) then 1 else 0 end ) as InvalidWeight, 
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_weight_g)>0 ) then 1 else 0 end ) as ValidWeight,
		sum(case when (p.product_weight_g is not null and TRY_CONVERT(decimal(10,2),p.product_weight_g) is null) then 1 else 0 end ) as NonNumericWeight,
		sum(case when (p.product_weight_g IS NULL) then 1 else 0 end) as NullWeight
from stg_products as p

select count(*) as TotalProducts,
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_length_cm)<=0) then 1 else 0 end ) as InvalidLength, 
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_length_cm)>0 ) then 1 else 0 end ) as ValidLength,
		sum(case when (p.product_length_cm is not null and TRY_CONVERT(decimal(10,2),p.product_length_cm) is null) then 1 else 0 end ) as NonNumericLength,
		sum(case when (p.product_length_cm IS NULL) then 1 else 0 end) as NullLength
from stg_products as p

select count(*) as TotalProducts,
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_height_cm)<=0) then 1 else 0 end ) as InvalidHeight, 
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_height_cm)>0 ) then 1 else 0 end ) as ValidHeight,
		sum(case when (p.product_height_cm is not null and TRY_CONVERT(decimal(10,2),p.product_height_cm) is null) then 1 else 0 end ) as NonNumericHeight,
		sum(case when (p.product_height_cm IS NULL) then 1 else 0 end) as NullHeight
from stg_products as p

select count(*) as TotalProducts,
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_width_cm)<=0) then 1 else 0 end ) as InvalidWidth, 
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_width_cm)>0 ) then 1 else 0 end ) as ValidWidth,
		sum(case when (p.product_width_cm is not null and TRY_CONVERT(decimal(10,2),p.product_width_cm) is null) then 1 else 0 end ) as NonNumericWidth,
		sum(case when (p.product_width_cm IS NULL) then 1 else 0 end) as NullWidth
from stg_products as p

select count(*) as TotalProducts,
		sum(case when (TRY_CONVERT(int,p.product_photos_qty)<0) then 1 else 0 end ) as InvalidPhotoQty, 
		sum(case when (TRY_CONVERT(int,p.product_photos_qty)>=0 ) then 1 else 0 end ) as ValidPhotoQty,
		sum(case when (p.product_photos_qty is not null and TRY_CONVERT(int,p.product_photos_qty) is null) then 1 else 0 end ) as NonNumericPhotoQty,
		sum(case when (p.product_photos_qty IS NULL) then 1 else 0 end) as NullPhotoQty
from stg_products as p

select count(*) as TotalProducts,
		sum(case when (TRY_CONVERT(int,p.product_description_lenght)<0) then 1 else 0 end ) as InvalidDescriptionLength, 
		sum(case when (TRY_CONVERT(int,p.product_description_lenght)>=0 ) then 1 else 0 end ) as ValidDescriptionLength,
		sum(case when (p.product_description_lenght is not null and TRY_CONVERT(int,p.product_description_lenght) is null) then 1 else 0 end ) as NonNumericDescriptionLength,
		sum(case when (p.product_description_lenght IS NULL) then 1 else 0 end) as NullDescriptionLength
from stg_products as p

select count(*) as TotalProducts,
		sum(case when (TRY_CONVERT(int,p.product_name_lenght)<0) then 1 else 0 end ) as InvalidNameLength, 
		sum(case when (TRY_CONVERT(int,p.product_name_lenght)>=0 ) then 1 else 0 end ) as ValidNameLength,
		sum(case when (p.product_name_lenght is not null and TRY_CONVERT(int,p.product_name_lenght) is null) then 1 else 0 end ) as NonNumericNameLength,
		sum(case when (p.product_name_lenght IS NULL) then 1 else 0 end) as NullNameLength
from stg_products as p

select count(*) as TotalProducts,
		
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_weight_g)<=0) then 1 else 0 end ) as InvalidWeight, 
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_weight_g)>0 ) then 1 else 0 end ) as ValidWeight,
		sum(case when (p.product_weight_g is not null and TRY_CONVERT(decimal(10,2),p.product_weight_g) is null) then 1 else 0 end ) as NonNumericWeight,
		sum(case when (p.product_weight_g IS NULL) then 1 else 0 end) as NullWeight,

		sum(case when (TRY_CONVERT(decimal(10,2),p.product_length_cm)<=0) then 1 else 0 end ) as InvalidLength, 
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_length_cm)>0 ) then 1 else 0 end ) as ValidLength,
		sum(case when (p.product_length_cm is not null and TRY_CONVERT(decimal(10,2),p.product_length_cm) is null) then 1 else 0 end ) as NonNumericLength,
		sum(case when (p.product_length_cm IS NULL) then 1 else 0 end) as NullLength,

		sum(case when (TRY_CONVERT(decimal(10,2),p.product_height_cm)<=0) then 1 else 0 end ) as InvalidHeight, 
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_height_cm)>0 ) then 1 else 0 end ) as ValidHeight,
		sum(case when (p.product_height_cm is not null and TRY_CONVERT(decimal(10,2),p.product_height_cm) is null) then 1 else 0 end ) as NonNumericHeight,
		sum(case when (p.product_height_cm IS NULL) then 1 else 0 end) as NullHeight,

		sum(case when (TRY_CONVERT(decimal(10,2),p.product_width_cm)<=0) then 1 else 0 end ) as InvalidWidth, 
		sum(case when (TRY_CONVERT(decimal(10,2),p.product_width_cm)>0 ) then 1 else 0 end ) as ValidWidth,
		sum(case when (p.product_width_cm is not null and TRY_CONVERT(decimal(10,2),p.product_width_cm) is null) then 1 else 0 end ) as NonNumericWidth,
		sum(case when (p.product_width_cm IS NULL) then 1 else 0 end) as NullWidth,

		sum(case when (TRY_CONVERT(int,p.product_photos_qty)<0) then 1 else 0 end ) as InvalidPhotoQty, 
		sum(case when (TRY_CONVERT(int,p.product_photos_qty)>=0 ) then 1 else 0 end ) as ValidPhotoQty,
		sum(case when (p.product_photos_qty is not null and TRY_CONVERT(int,p.product_photos_qty) is null) then 1 else 0 end ) as NonNumericPhotoQty,
		sum(case when (p.product_photos_qty IS NULL) then 1 else 0 end) as NullPhotoQty,

		sum(case when (TRY_CONVERT(int,p.product_description_lenght)<0) then 1 else 0 end ) as InvalidDescriptionLength, 
		sum(case when (TRY_CONVERT(int,p.product_description_lenght)>=0 ) then 1 else 0 end ) as ValidDescriptionLength,
		sum(case when (p.product_description_lenght is not null and TRY_CONVERT(int,p.product_description_lenght) is null) then 1 else 0 end ) as NonNumericDescriptionLength,
		sum(case when (p.product_description_lenght IS NULL) then 1 else 0 end) as NullDescriptionLength,

		sum(case when (TRY_CONVERT(int,p.product_name_lenght)<0) then 1 else 0 end ) as InvalidNameLength, 
		sum(case when (TRY_CONVERT(int,p.product_name_lenght)>=0 ) then 1 else 0 end ) as ValidNameLength,
		sum(case when (p.product_name_lenght is not null and TRY_CONVERT(int,p.product_name_lenght) is null) then 1 else 0 end ) as NonNumericNameLength,
		sum(case when (p.product_name_lenght IS NULL) then 1 else 0 end) as NullNameLength
from stg_products as p

select count(*) as TotalOrderPayment,
		sum(case when (TRY_CONVERT(int,op.payment_sequential)<=0) then 1 else 0 end ) as InvalidSequential, 
		sum(case when (TRY_CONVERT(int,op.payment_sequential)>0 ) then 1 else 0 end ) as ValidSequential,
		sum(case when (op.payment_sequential is not null and TRY_CONVERT(int,op.payment_sequential) is null) then 1 else 0 end ) as NonNumericSequential,
		sum(case when (op.payment_sequential IS NULL) then 1 else 0 end) as NullSequential,

		sum(case when (TRY_CONVERT(int,op.payment_installments)<=0) then 1 else 0 end ) as InvalidInstallments, 
		sum(case when (TRY_CONVERT(int,op.payment_installments)>0 ) then 1 else 0 end ) as ValidInstallments,
		sum(case when (op.payment_installments is not null and TRY_CONVERT(int,op.payment_installments) is null) then 1 else 0 end ) as NonNumericInstallments,
		sum(case when (op.payment_installments IS NULL) then 1 else 0 end) as NullInstallments,

		sum(case when (TRY_CONVERT(decimal(10,2),op.payment_value)<=0) then 1 else 0 end ) as InvalidPayment_value, 
		sum(case when (TRY_CONVERT(decimal(10,2),op.payment_value)>0 ) then 1 else 0 end ) as ValidPayment_value,
		sum(case when (op.payment_value is not null and TRY_CONVERT(decimal(10,2),op.payment_value) is null) then 1 else 0 end ) as NonNumericPayment_value,
		sum(case when (op.payment_value IS NULL) then 1 else 0 end) as NullPayment_value

from stg_order_payments as op

select op.order_id,op.payment_installments,op.payment_sequential,op.payment_type,op.payment_value
from stg_order_payments as op
where TRY_CONVERT(decimal(10,2),op.payment_value)<=0;

select op.payment_type, count(*)as TotalRecord,
		sum(case when (TRY_CONVERT(decimal(10,2),op.payment_value) = 0 ) then 1 else 0 end)as PaymentZero,
		sum(case when (TRY_CONVERT(decimal(10,2),op.payment_value) > 0 ) then 1 else 0 end )as PaymentGreaterThanZero
from stg_order_payments as op
group by op.payment_type
order by TotalRecord desc;

select op.payment_type, count(*)as TotalRecord,
		sum(case when (TRY_CONVERT(int,op.payment_installments) = 0 ) then 1 else 0 end)as installmentsZero,
		sum(case when (TRY_CONVERT(int,op.payment_installments) > 0 ) then 1 else 0 end )as installmentsGreaterThanZero
from stg_order_payments as op
group by op.payment_type
order by TotalRecord desc;

select op.order_id,op.payment_sequential,op.payment_type,op.payment_installments, op.payment_value
from stg_order_payments as op
where TRY_CONVERT(int,op.payment_installments)=0;

select o.order_status,
o.order_purchase_timestamp,
o.order_id, op.payment_sequential,
op.payment_type,
op.payment_installments,
op.payment_value
from stg_orders as o
inner join stg_order_payments as op on o.order_id = op.order_id
where TRY_CONVERT(int,op.payment_installments)=0;

select distinct op.payment_type,count(*) as totalRecords
from stg_order_payments as op
group by op.payment_type;

---------------

select count(*) as TotalOrders,
		sum(case when (o.order_purchase_timestamp IS not NULL and TRY_CONVERT(datetime2,o.order_purchase_timestamp)is null) then 1 else 0 end ) as InvalidTimestamp, 
		sum(case when (TRY_CONVERT(datetime2,o.order_purchase_timestamp)is not null ) then 1 else 0 end ) as ValidTimestamp,
		sum(case when (o.order_purchase_timestamp IS NULL) then 1 else 0 end) as NullTimestamp,

		sum(case when (o.order_approved_at IS not NULL and TRY_CONVERT(datetime2,o.order_approved_at)is null) then 1 else 0 end ) as InvalidApproved, 
		sum(case when (TRY_CONVERT(datetime2,o.order_approved_at)is not null ) then 1 else 0 end ) as ValidInvalidApproved,
		sum(case when (o.order_approved_at IS NULL) then 1 else 0 end) as NullInvalidApproved,

		sum(case when (o.order_delivered_carrier_date IS not NULL and TRY_CONVERT(datetime2,o.order_delivered_carrier_date)is null) then 1 else 0 end ) as InvalidDelivered_carrier_date, 
		sum(case when (TRY_CONVERT(datetime2,o.order_delivered_carrier_date)is not null ) then 1 else 0 end ) as ValidDelivered_carrier_date,
		sum(case when (o.order_delivered_carrier_date IS NULL) then 1 else 0 end) as NullDelivered_carrier_date,

		sum(case when (o.order_delivered_customer_date IS not NULL and TRY_CONVERT(datetime2,o.order_delivered_customer_date)is null) then 1 else 0 end ) as InvalidDelivered_customer_date, 
		sum(case when (TRY_CONVERT(datetime2,o.order_delivered_customer_date)is not null ) then 1 else 0 end ) as ValidDelivered_customer_date,
		sum(case when (o.order_delivered_customer_date IS NULL) then 1 else 0 end) as NullDelivered_customer_date,

		sum(case when (o.order_estimated_delivery_date IS not NULL and TRY_CONVERT(datetime2,o.order_estimated_delivery_date)is null) then 1 else 0 end ) as Invalid_estimated_delivery_date, 
		sum(case when (TRY_CONVERT(datetime2,o.order_estimated_delivery_date)is not null ) then 1 else 0 end ) as Valid_estimated_delivery_date,
		sum(case when (o.order_estimated_delivery_date IS NULL) then 1 else 0 end) as Null_estimated_delivery_date

from stg_orders as o;

SELECT
    COUNT(*) AS TotalOrders,

    SUM(CASE
        WHEN o.order_purchase_timestamp IS NOT NULL
         AND o.order_approved_at IS NOT NULL
         AND TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)
             <= TRY_CONVERT(DATETIME2, o.order_approved_at)
        THEN 1 ELSE 0
    END) AS ValidChronology,

    SUM(CASE
        WHEN o.order_purchase_timestamp IS NOT NULL
         AND o.order_approved_at IS NOT NULL
         AND TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)
             > TRY_CONVERT(DATETIME2, o.order_approved_at)
        THEN 1 ELSE 0
    END) AS InvalidChronology,
    SUM(CASE
        WHEN o.order_purchase_timestamp IS NULL
          OR o.order_approved_at IS NULL
        THEN 1 ELSE 0
    END) AS MissingDates

FROM stg_orders AS o;

SELECT
    COUNT(*) AS TotalOrders,

    SUM(CASE
        WHEN o.order_approved_at IS NOT NULL
         AND o.order_delivered_carrier_date IS NOT NULL
         AND TRY_CONVERT(DATETIME2, o.order_approved_at)
             <= TRY_CONVERT(DATETIME2, o.order_delivered_carrier_date)
        THEN 1 ELSE 0
    END) AS ValidChronology,

    SUM(CASE
        WHEN o.order_approved_at IS NOT NULL
         AND o.order_delivered_carrier_date IS NOT NULL
         AND TRY_CONVERT(DATETIME2, o.order_approved_at)
             > TRY_CONVERT(DATETIME2, o.order_delivered_carrier_date)
        THEN 1 ELSE 0
    END) AS InvalidChronology,
    SUM(CASE
        WHEN o.order_approved_at IS NULL
          OR o.order_delivered_carrier_date IS NULL
        THEN 1 ELSE 0
    END) AS MissingDates

FROM stg_orders AS o;

SELECT
    COUNT(*) AS TotalOrders,

    SUM(CASE
        WHEN o.order_delivered_carrier_date IS NOT NULL
         AND o.order_delivered_customer_date IS NOT NULL
         AND TRY_CONVERT(DATETIME2, o.order_delivered_carrier_date)
             <= TRY_CONVERT(DATETIME2, o.order_delivered_customer_date)
        THEN 1 ELSE 0
    END) AS ValidChronology,

    SUM(CASE
        WHEN o.order_delivered_carrier_date IS NOT NULL
         AND o.order_delivered_customer_date IS NOT NULL
         AND TRY_CONVERT(DATETIME2, o.order_delivered_carrier_date)
             > TRY_CONVERT(DATETIME2, o.order_delivered_customer_date)
        THEN 1 ELSE 0
    END) AS InvalidChronology,
    SUM(CASE
        WHEN o.order_delivered_carrier_date IS NULL
          OR o.order_delivered_customer_date IS NULL
        THEN 1 ELSE 0
    END) AS MissingDates

FROM stg_orders AS o;

SELECT
    COUNT(*) AS TotalOrders,

    SUM(CASE
        WHEN o.order_purchase_timestamp IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
         AND TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)
             <= TRY_CONVERT(DATETIME2, o.order_estimated_delivery_date)
        THEN 1 ELSE 0
    END) AS ValidChronology,

    SUM(CASE
        WHEN o.order_purchase_timestamp IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
         AND TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)
             > TRY_CONVERT(DATETIME2, o.order_estimated_delivery_date)
        THEN 1 ELSE 0
    END) AS InvalidChronology,
    SUM(CASE
        WHEN o.order_purchase_timestamp IS NULL
          OR o.order_estimated_delivery_date IS NULL
        THEN 1 ELSE 0
    END) AS MissingDates

FROM stg_orders AS o;

select top(10) o.order_id,o.order_status,o.order_approved_at,o.order_delivered_carrier_date
from stg_orders as o 
where (o.order_approved_at is not null and o.order_delivered_carrier_date is not null)
	  and TRY_CONVERT(datetime2,o.order_approved_at)>TRY_CONVERT(datetime2,o.order_estimated_delivery_date)

SELECT
    YEAR(TRY_CONVERT(DATETIME2, order_approved_at)) AS ApprovalYear,
    MONTH(TRY_CONVERT(DATETIME2, order_approved_at)) AS ApprovalMonth,
    COUNT(*) AS AnomalyCount
FROM dbo.stg_orders
WHERE
    order_approved_at IS NOT NULL
    AND order_delivered_carrier_date IS NOT NULL
    AND TRY_CONVERT(DATETIME2, order_approved_at) IS NOT NULL
    AND TRY_CONVERT(DATETIME2, order_delivered_carrier_date) IS NOT NULL
    AND TRY_CONVERT(DATETIME2, order_delivered_carrier_date)
        < TRY_CONVERT(DATETIME2, order_approved_at)
GROUP BY
    YEAR(TRY_CONVERT(DATETIME2, order_approved_at)),
    MONTH(TRY_CONVERT(DATETIME2, order_approved_at))
ORDER BY
    ApprovalYear,
    ApprovalMonth;

	----------------------------------

	SELECT order_status,
    COUNT(*) AS AnomalyCount
FROM dbo.stg_orders
WHERE
    order_approved_at IS NOT NULL
    AND order_delivered_carrier_date IS NOT NULL
    AND TRY_CONVERT(DATETIME2, order_approved_at) IS NOT NULL
    AND TRY_CONVERT(DATETIME2, order_delivered_carrier_date) IS NOT NULL
    AND YEAR(TRY_CONVERT(DATETIME2, order_approved_at)) = 2018 
	AND MONTH(TRY_CONVERT(DATETIME2, order_approved_at)) = 7
	AND TRY_CONVERT(DATETIME2, order_delivered_carrier_date)
    < TRY_CONVERT(DATETIME2, order_approved_at)
GROUP BY
    order_status

	SELECT
    YEAR(TRY_CONVERT(DATETIME2, order_approved_at)) AS ApprovalYear,
    MONTH(TRY_CONVERT(DATETIME2, order_approved_at)) AS ApprovalMonth,
	Day(TRY_CONVERT(DATETIME2, order_approved_at)) AS ApprovalDay,
    COUNT(*) AS AnomalyCount
FROM dbo.stg_orders
WHERE
    order_approved_at IS NOT NULL
    AND order_delivered_carrier_date IS NOT NULL
    AND TRY_CONVERT(DATETIME2, order_approved_at) IS NOT NULL
    AND TRY_CONVERT(DATETIME2, order_delivered_carrier_date) IS NOT NULL
    AND TRY_CONVERT(DATETIME2, order_delivered_carrier_date)
        < TRY_CONVERT(DATETIME2, order_approved_at)
GROUP BY
    YEAR(TRY_CONVERT(DATETIME2, order_approved_at)),
    MONTH(TRY_CONVERT(DATETIME2, order_approved_at)),
	Day(TRY_CONVERT(DATETIME2, order_approved_at))
ORDER BY
    ApprovalYear,
    ApprovalMonth,ApprovalDay;



	SELECT
    order_id,
    order_status,
    order_approved_at,
    order_delivered_carrier_date,
    DATEDIFF(
        MINUTE,
        TRY_CONVERT(DATETIME2, order_delivered_carrier_date),
        TRY_CONVERT(DATETIME2, order_approved_at)
    ) AS DifferenceInMinutes
FROM dbo.stg_orders
WHERE
    order_status = 'delivered'
    AND TRY_CONVERT(DATETIME2, order_approved_at) >= '2018-07-05'
    AND TRY_CONVERT(DATETIME2, order_approved_at) < '2018-07-06'
    AND TRY_CONVERT(DATETIME2, order_delivered_carrier_date)
        < TRY_CONVERT(DATETIME2, order_approved_at)
ORDER BY DifferenceInMinutes DESC;

SELECT
    CAST(
        TRY_CONVERT(DATETIME2, order_approved_at)
        AS DATE
    ) AS ApprovalDate,
    DATEPART(
        HOUR,
        TRY_CONVERT(DATETIME2, order_approved_at)
    ) AS ApprovalHour,
    COUNT(*) AS OrderCount
FROM dbo.stg_orders
WHERE
    order_status = 'delivered'
    AND TRY_CONVERT(DATETIME2, order_approved_at) >= '2018-07-05'
    AND TRY_CONVERT(DATETIME2, order_approved_at) < '2018-07-06'
    AND TRY_CONVERT(DATETIME2, order_delivered_carrier_date)
        < TRY_CONVERT(DATETIME2, order_approved_at)
GROUP BY
    CAST(TRY_CONVERT(DATETIME2, order_approved_at) AS DATE),
    DATEPART(HOUR, TRY_CONVERT(DATETIME2, order_approved_at))
ORDER BY ApprovalHour;

SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_estimated_delivery_date
FROM dbo.stg_orders
WHERE
    order_purchase_timestamp IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
    AND TRY_CONVERT(DATETIME2, order_purchase_timestamp)
        >
        TRY_CONVERT(DATETIME2, order_estimated_delivery_date);


		SELECT
    COUNT(*) AS TotalOrders,

    SUM(CASE
        WHEN order_purchase_timestamp IS NULL
          OR order_estimated_delivery_date IS NULL
        THEN 1 ELSE 0
    END) AS MissingDates,

    SUM(CASE
        WHEN order_purchase_timestamp IS NOT NULL
         AND TRY_CONVERT(DATETIME2, order_purchase_timestamp) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidPurchaseDates,

    SUM(CASE
        WHEN order_estimated_delivery_date IS NOT NULL
         AND TRY_CONVERT(DATETIME2, order_estimated_delivery_date) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidEstimatedDates,

    SUM(CASE
        WHEN TRY_CONVERT(DATETIME2, order_purchase_timestamp) IS NOT NULL
         AND TRY_CONVERT(DATETIME2, order_estimated_delivery_date) IS NOT NULL
         AND TRY_CONVERT(DATETIME2, order_purchase_timestamp)
             > TRY_CONVERT(DATETIME2, order_estimated_delivery_date)
        THEN 1 ELSE 0
    END) AS PurchaseAfterEstimated

FROM dbo.stg_orders;

-------------------------------------------------------------
select count(*) as TotalRows,
	   sum(case when (oi.shipping_limit_date is not null and TRY_CONVERT(datetime2, oi.shipping_limit_date) is null) then 1 else 0 end)as InvalidDates,
	   sum(case when (TRY_CONVERT(datetime2, oi.shipping_limit_date) is not null) then 1 else 0 end)as ValidDates,
	   sum(case when oi.shipping_limit_date is null then 1 else 0 end)as NULLDates
from stg_order_items as oi

select count(*) as TotalRows,
		sum(case when (TRY_CONVERT(int,oi.order_item_id)>0  ) then 1 else 0 end) as ValidIntegers,
		sum(case when ( TRY_CONVERT(int,oi.order_item_id)<=0) then 1 else 0 end)as InvalidId,
		sum(case when (oi.order_item_id is not null and TRY_CONVERT(int,oi.order_item_id) is null ) then 1 else 0 end)as Non_numericvalues,
		sum(case when (oi.order_item_id is null) then 1 else 0 end)as NullValue 
from stg_order_items as oi

select count(*) as totalRows
from stg_order_items as oi
where TRY_CONVERT(decimal(10,2),oi.freight_value) >= TRY_CONVERT(decimal(10,2),oi.price)*2;

select count(*) as totalRows
from stg_order_items as oi
where TRY_CONVERT(decimal(10,2),oi.freight_value) > TRY_CONVERT(decimal(10,2),oi.price);

select oi.order_id,oi.order_item_id,oi.product_id,oi.price,oi.freight_value
from stg_order_items as oi
where TRY_CONVERT(decimal(10,2),oi.freight_value) >= TRY_CONVERT(decimal(10,2),oi.price)*2;

select count(*)as totalRows, count(distinct oi.order_id) as UniqueId
from stg_order_items as oi
where TRY_CONVERT(decimal(10,2),oi.freight_value) >= TRY_CONVERT(decimal(10,2),oi.price)*2;

select oi.order_id,count(oi.order_id) as matchingOrder
from stg_order_items as oi
WHERE TRY_CONVERT(decimal(10,2), oi.freight_value)
      >= TRY_CONVERT(decimal(10,2), oi.price) * 2
group by oi.order_id
having count(oi.order_id)>1

select count(*)as unMachedRecord
from stg_order_items as oi
left join stg_orders as o on oi.order_id = o.order_id
where o.order_id is null

select count(*) as unMachedRecord
from stg_order_items as oi
left join stg_products as p on oi.product_id = p.product_id
where p.product_id is null

select count(*) as unMachedRecord
from stg_order_items as oi
left join stg_sellers as s on oi.seller_id = s.seller_id
where s.seller_id is null

select oi.order_item_id, oi.order_id, COUNT(*) as totalAppear
from stg_order_items as oi
group by oi.order_item_id,oi.order_id
having COUNT(*)>1

--------------------------------------------------

select  count(*) as TotalRows,
		sum(case when (trim(c.customer_id)='' and c.customer_id is not null) then 1 else 0 end )as emptyString
from stg_customers as c

select c.customer_id, count(*)as totalDuplicate
from stg_customers as c
group by c.customer_id
having count(*)>1

select count(*) as totalRows, 
	   sum(case when (len(c.customer_zip_code_prefix)!=5) then 1 else 0 end )as invalidCode,
	   sum(case when ( TRY_CONVERT(int,c.customer_zip_code_prefix)is null) then 1 else 0 end )as Non_NomaricValues
from stg_customers as c

select distinct c.customer_state
from stg_customers as c
order by c.customer_state;

select count(*) as totalRows, sum(case when ( c.customer_state not in ('AC','AL',
'AM',
'AP',
'BA',
'CE',
'DF',
'ES',
'GO',
'MA',
'MG',
'MS',
'MT',
'PA',
'PB',
'PE',
'PI',
'PR',
'RJ',
'RN',
'RO',
'RR',
'RS',
'SC',
'SE',
'SP',
'TO') ) then 1 else 0 end) as invalidStat
from stg_customers as c

select count(*)as totalRows, 
	   sum( case when c.customer_city is not null then 1 else 0 end )as notNull,
	   sum( case when trim(c.customer_city) = '' then 1 else 0 end )as emptyString,
	   SUM(CASE WHEN c.customer_city IS NULL THEN 1 ELSE 0 END) AS NullCities
from stg_customers as c

select count(*) as totalRows,count(distinct c.customer_city) as uniqueCity
from stg_customers as c
 
select c.customer_city, count(distinct c.customer_state) as numberOfStats
from stg_customers as c
group by c.customer_city
having COUNT(DISTINCT c.customer_state) > 1;

select c.customer_city,c.customer_state, count(*)as totalnumber
from stg_customers as c
group by c.customer_city,c.customer_state

select c.customer_zip_code_prefix, count(distinct c.customer_state)as uniqueState
from stg_customers as c
group by c.customer_zip_code_prefix
having COUNT(distinct c.customer_state)>1

select count(*) as totalUnmached
from stg_orders as o
left join stg_customers as c on o.customer_id = c.customer_id
where c.customer_id is null 

select count(*) as totalUnmached
from stg_customers as c
left join stg_orders  as o on o.customer_id = c.customer_id
where o.customer_id is null 

select count(*) as TotalRows, 
		sum(case when (TRY_CONVERT( decimal(10,6),g.geolocation_lat ) between -90 and 90) then 1 else 0 end)as validatLatValue,
		sum(case when (TRY_CONVERT( decimal(10,6),g.geolocation_lat )not between -90 and 90) then 1 else 0 end)as InvalidatLatValue,
		sum(case when (g.geolocation_lat is not null and TRY_CONVERT( decimal(10,6),g.geolocation_lat )is null) then 1 else 0 end)as nonNumaricValue,
		sum(case when g.geolocation_lat is null then 1 else 0 end )as nullValue
from stg_geolocations as g

select count(*) as TotalRows, 
		sum(case when (TRY_CONVERT( decimal(10,6),g.geolocation_lng ) between -180 and 180) then 1 else 0 end)as validatLngValue,
		sum(case when (TRY_CONVERT( decimal(10,6),g.geolocation_lng )not between -180 and 180) then 1 else 0 end)as InvalidatLngValue,
		sum(case when (g.geolocation_lng is not null and TRY_CONVERT( decimal(10,6),g.geolocation_lng )is null) then 1 else 0 end)as nonNumaricValue,
		sum(case when g.geolocation_lng is null then 1 else 0 end )as nullValue
from stg_geolocations as g
select count(*)as TotalRows,
		sum(case when len(g.geolocation_zip_code_prefix)<>5 then 1 else 0 end)as invaliedLength,
		sum(case when g.geolocation_zip_code_prefix is not null and TRY_CONVERT(int,g.geolocation_zip_code_prefix) is null then 1 else 0 end)as nonNumarickValues,
		sum(case when g.geolocation_zip_code_prefix is null then 1 else 0 end)as nullValues
from stg_geolocations as g

select count(*)as totalRows,
	   sum(case when g.geolocation_city is null then 1 else 0 end)as nullValues,
	   sum(case when trim(g.geolocation_city) = '' then 1 else 0 end)as emptyCity,
	   sum(case when g.geolocation_city like '% ' then 1 else 0 end)as endWithSpace
from stg_geolocations as g

SELECT
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state,
    LEN(geolocation_city) AS cityLength
FROM dbo.stg_geolocations
WHERE geolocation_city LIKE '% ';

select g.geolocation_zip_code_prefix, count(distinct g.geolocation_state)as uniqueState 
from stg_geolocations as g
group by g.geolocation_zip_code_prefix
having count(distinct g.geolocation_state) >1;

SELECT
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state
FROM dbo.stg_geolocations
WHERE geolocation_zip_code_prefix IN
(
    '23056', '02116', '80630', '72915',
    '79750', '04011', '78557', '21550'
)
ORDER BY geolocation_zip_code_prefix, geolocation_state;


SELECT
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state,
	count(*) numberOfRecord
FROM dbo.stg_geolocations
WHERE geolocation_zip_code_prefix IN
(
    '23056', '02116', '80630', '72915',
    '79750', '04011', '78557', '21550'
)
group BY geolocation_zip_code_prefix,geolocation_city, geolocation_state;
SELECT
    g.geolocation_zip_code_prefix,
    g.geolocation_state,
    COUNT(*) AS TotalRows,
    MIN(TRY_CONVERT(DECIMAL(10,6), g.geolocation_lat)) AS MinimumLat,
    MAX(TRY_CONVERT(DECIMAL(10,6), g.geolocation_lat)) AS MaximumLat,
    MIN(TRY_CONVERT(DECIMAL(10,6), g.geolocation_lng)) AS MinimumLng,
    MAX(TRY_CONVERT(DECIMAL(10,6), g.geolocation_lng)) AS MaximumLng
FROM dbo.stg_geolocations AS g
WHERE g.geolocation_zip_code_prefix IN
(
    '23056', '02116', '80630', '72915',
    '79750', '04011', '78557', '21550'
)
GROUP BY
    g.geolocation_zip_code_prefix,
    g.geolocation_state;

select count(*)as TotalRows, sum(case when s.seller_id is null then 1 else 0 end) as  NullIds,
	   sum(case when s.seller_id is not null and (trim(s.seller_id) = '') then 1 else 0 end)as emptySpaces
from stg_sellers as s

select s.seller_id,count(*)as totalRows
from stg_sellers as s
group by s.seller_id
having count(*)>1;

select count(*)as TotalRows,
	   sum(case when (s.seller_zip_code_prefix) is null then 1 else 0 end )as nullZipCode,
	   sum(case when (s.seller_zip_code_prefix is not null and trim(s.seller_zip_code_prefix)='' ) then 1 else 0 end)as emptyZip,
	   sum(case when len(s.seller_zip_code_prefix)<>5 then 1 else 0 end )as not5Char,
	   sum(case when (s.seller_zip_code_prefix is not null and TRY_CONVERT(int,s.seller_zip_code_prefix)is null)then 1 else 0 end  )as noNomaricZip
from stg_sellers as s

select count(*) as totalRows, sum(case when ( s.seller_state not in ('AC','AL',
'AM',
'AP',
'BA',
'CE',
'DF',
'ES',
'GO',
'MA',
'MG',
'MS',
'MT',
'PA',
'PB',
'PE',
'PI',
'PR',
'RJ',
'RN',
'RO',
'RR',
'RS',
'SC',
'SE',
'SP',
'TO') ) then 1 else 0 end) as invalidStat
from stg_sellers as s

select count(*)as totalRows, 
	   sum( case when s.seller_city is not null then 1 else 0 end )as notNull,
	   sum( case when trim(s.seller_city) = '' then 1 else 0 end )as emptyString,
	   SUM(CASE WHEN s.seller_city IS NULL THEN 1 ELSE 0 END) AS NullCities,
	   SUM(CASE
    WHEN s.seller_city LIKE '% ' THEN 1
    ELSE 0
END) AS TrailingSpaces
from stg_sellers as s

select count(*)as valueNotExist
from stg_order_items as oi
left join stg_sellers as s on s.seller_id = oi.seller_id
where s.seller_id is null;

select count(*)as totalRows, 
	   sum( case when s.product_category_name is not null then 1 else 0 end )as notNullCategory_name,
	   sum( case when trim(s.product_category_name) = '' then 1 else 0 end )as emptyCategory_name,
	   SUM(CASE WHEN s.product_category_name IS NULL THEN 1 ELSE 0 END) AS NullCategory_name,

	   sum( case when s.product_category_name_english is not null then 1 else 0 end )as notNullCategory_name_english,
	   sum( case when trim(s.product_category_name_english) = '' then 1 else 0 end )as emptyCategory_name_english,
	   SUM(CASE WHEN s.product_category_name_english IS NULL THEN 1 ELSE 0 END) AS NullCategory_name_english
from stg_product_category_name_translation as s

select s.product_category_name,count(*)as totalRows
from stg_product_category_name_translation as s
group by s.product_category_name
having count(*)>1;

select s.product_category_name_english,count(*)as totalRows
from stg_product_category_name_translation as s
group by s.product_category_name_english
having count(*)>1;

select count(*)as valueNotExist
from stg_products as p
left join stg_product_category_name_translation as pc on p.product_category_name = pc.product_category_name
 WHERE pc.product_category_name IS NULL;

SELECT
    COUNT(*) AS TotalUnmatched,
    SUM(CASE
        WHEN p.product_category_name IS NULL THEN 1
        ELSE 0
    END) AS NullCategory,
    SUM(CASE
        WHEN p.product_category_name IS NOT NULL THEN 1
        ELSE 0
    END) AS CategoryWithoutTranslation
FROM dbo.stg_products AS p
LEFT JOIN dbo.stg_product_category_name_translation AS pc
    ON p.product_category_name = pc.product_category_name
WHERE pc.product_category_name IS NULL;

SELECT
    p.product_category_name,
    COUNT(*) AS TotalProducts
FROM dbo.stg_products AS p
LEFT JOIN dbo.stg_product_category_name_translation AS pc
    ON p.product_category_name = pc.product_category_name
WHERE pc.product_category_name IS NULL
  AND p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY TotalProducts DESC;

SELECT *
FROM dbo.stg_product_category_name_translation
WHERE product_category_name LIKE '%portateis%'
   OR product_category_name LIKE '%pc_gamer%';





