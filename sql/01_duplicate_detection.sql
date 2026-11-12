/*
PROJECT: Olist E-commerce Data Engineering

MODULE: Data Quality
TASK: Duplicate Detection

PURPOSE:
Identify duplicate business keys and exact
duplicate records in staging tables.

DATABASE: OlistDataWarehouse
*/


use OlistDataWarehouse;

select c.customer_id,count(*) as totalDuplicats
from stg_customers as c
group by c.customer_id
having count(*)>1
order by totalDuplicats desc

SELECT
    COUNT(*) AS TotalCustomers,
    COUNT(DISTINCT customer_id) AS UniqueCustomerIDs,
    COUNT(*) - COUNT(DISTINCT customer_id) AS DuplicateDifference
FROM dbo.stg_customers;

select 
g.geolocation_zip_code_prefix, 
COUNT(g.geolocation_zip_code_prefix) as duplicateZipCodes,
count(*)as totalcites
from stg_geolocations as g
group by  g.geolocation_zip_code_prefix
having  count(g.geolocation_zip_code_prefix)>1
--order by duplicateCites desc count(g.geolocation_city)>1 or g.geolocation_city, --count(g.geolocation_city) as duplicateCites,


-- Olist: Duplicate Key Audit

SELECT
    'stg_customers' AS TableName,
    COUNT(*) AS DuplicateGroups,
    SUM(DuplicateCount - 1) AS ExtraRows
FROM (
    SELECT COUNT(*) AS DuplicateCount
    FROM dbo.stg_customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) AS D

UNION ALL

SELECT
    'stg_orders',
    COUNT(*),
    SUM(DuplicateCount - 1)
FROM (
    SELECT COUNT(*) AS DuplicateCount
    FROM dbo.stg_orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
) AS D

UNION ALL

SELECT
    'stg_order_items',
    COUNT(*),
    SUM(DuplicateCount - 1)
FROM (
    SELECT COUNT(*) AS DuplicateCount
    FROM dbo.stg_order_items
    GROUP BY order_id, order_item_id
    HAVING COUNT(*) > 1
) AS D

UNION ALL

SELECT
    'stg_order_payments',
    COUNT(*),
    SUM(DuplicateCount - 1)
FROM (
    SELECT COUNT(*) AS DuplicateCount
    FROM dbo.stg_order_payments
    GROUP BY order_id, payment_sequential
    HAVING COUNT(*) > 1
) AS D

UNION ALL

SELECT
    'stg_order_reviews',
    COUNT(*),
    SUM(DuplicateCount - 1)
FROM (
    SELECT COUNT(*) AS DuplicateCount
    FROM dbo.stg_order_reviews
    GROUP BY review_id, order_id
    HAVING COUNT(*) > 1
) AS D

UNION ALL

SELECT
    'stg_products',
    COUNT(*),
    SUM(DuplicateCount - 1)
FROM (
    SELECT COUNT(*) AS DuplicateCount
    FROM dbo.stg_products
    GROUP BY product_id
    HAVING COUNT(*) > 1
) AS D

UNION ALL

SELECT
    'stg_sellers',
    COUNT(*),
    SUM(DuplicateCount - 1)
FROM (
    SELECT COUNT(*) AS DuplicateCount
    FROM dbo.stg_sellers
    GROUP BY seller_id
    HAVING COUNT(*) > 1
) AS D

UNION ALL

SELECT
    'stg_product_category_name_translation',
    COUNT(*),
    SUM(DuplicateCount - 1)
FROM (
    SELECT COUNT(*) AS DuplicateCount
    FROM dbo.stg_product_category_name_translation
    GROUP BY product_category_name
    HAVING COUNT(*) > 1
) AS D

UNION ALL

SELECT
    'stg_geolocations',
    COUNT(*),
    SUM(DuplicateCount - 1)
FROM (
    SELECT COUNT(*) AS DuplicateCount
    FROM dbo.stg_geolocations
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    HAVING COUNT(*) > 1
) AS D

ORDER BY TableName;

select g.geolocation_zip_code_prefix, count(*) as numberOfDuplicates
from stg_geolocations as g
group by g.geolocation_zip_code_prefix
having count(*)>1
order by numberOfDuplicates desc;

SELECT
    geolocation_zip_code_prefix,
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT geolocation_city) AS DistinctCities
FROM dbo.stg_geolocations
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1
ORDER BY TotalRecords DESC;

select g.geolocation_zip_code_prefix,
g.geolocation_lat,
g.geolocation_lng,
g.geolocation_city,
g.geolocation_state,
count(*) as TotalOccurrences
from stg_geolocations as g
group by g.geolocation_zip_code_prefix,g.geolocation_lat,g.geolocation_lng,g.geolocation_city,g.geolocation_state
having count(*)>1
order by TotalOccurrences desc

use OlistDataWarehouse;
select COUNT(*) as DuplicateGroups, sum(D.duplicatCount) as TotalOccurrences, (sum(D.duplicatCount) - count(*) ) as ExtraRows
from (select count(*) as duplicatCount
	  from stg_geolocations 
	  group by geolocation_zip_code_prefix,
	  geolocation_city,
	  geolocation_lat,
	  geolocation_lng,
	  geolocation_state	
	  having count(*)>1) as D;

select g.geolocation_zip_code_prefix as zip, g.geolocation_city as city, g.geolocation_state as state, count(*)as Occurrences 
from stg_geolocations as g
group by g.geolocation_zip_code_prefix,g.geolocation_city,g.geolocation_state,g.geolocation_lat,g.geolocation_lng
having count(*)>1
order by Occurrences desc 
use OlistDataWarehouse;

with GetRowNumber as(
select g.geolocation_zip_code_prefix as zip,
	   g.geolocation_city as city,
	   g.geolocation_lat as Latitude,
	   g.geolocation_lng,g.geolocation_state,
	   ROW_NUMBER() over (partition by g.geolocation_zip_code_prefix,
							g.geolocation_city,
							g.geolocation_lat,
							g.geolocation_lng,
							g.geolocation_state
							order by g.geolocation_city asc)as rowNumber
from stg_geolocations as g
)
select zip,city,Latitude,rowNumber
from GetRowNumber
where rowNumber>1;

with KeepUniqueRecord as(
select g.geolocation_zip_code_prefix,
	   g.geolocation_city,
	   g.geolocation_lat,
	   g.geolocation_lng,
	   g.geolocation_state,
	   ROW_NUMBER() over(partition by g.geolocation_zip_code_prefix,
	   g.geolocation_city,
	   g.geolocation_lat,
	   g.geolocation_lng,
	   g.geolocation_state order by  g.geolocation_city) as RowNumber
from stg_geolocations as g
)
select *
from KeepUniqueRecord
where RowNumber = 1;

with UniquePairs as(
select distinct g.geolocation_zip_code_prefix as zip,
	    g.geolocation_lat,
	    g.geolocation_lng
from stg_geolocations as g

),DistinctCoordinates as(
select zip,count(*) as pairs
from UniquePairs
group by zip
)
select *
from DistinctCoordinates
where pairs>1
order by pairs desc;





