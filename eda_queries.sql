/*EDA (EXPLORATORY DATA ANALYSIS)*/

/* OVERALL PERFORMANCE */

--1 Total Sales
select sum(sales) as total_sales from blinkit_cleaned

--2 Average Sale per item
select item_type,round(avg(sales),2) avg_sales_per_item from blinkit_cleaned
group by item_type
order by avg_sales_per_item desc

--3 How many Total Items are there 
select count(distinct item_id) as no_of_items from blinkit_cleaned

/*SALES BY CATEGORY */

--4 Which item category sells the most and most revenue 
select 
		item_type,
		sum(sales) total_sale,
		concat(round(sum(sales)*100.0 / sum(sum(sales)) over(),2),'%') as contribution_percentage
from blinkit_cleaned
group by item_type
order by total_sale desc
limit 5

--5 Which item category has lowest sale
SELECT item_type,count(*) total_transactions,sum(sales) as total_sales from blinkit_cleaned
group by item_type
order by total_sales asc
limit 5

/*OUTLET PERFORMANCE*/

--6 Which Outlet type generates highest revenue
select 
		outlet_type ,
		sum(sales) as total_revenue_per_outlet, 
		concat(round(sum(sales)*100.0/sum(sum(sales)) OVER(),2),'%') as percentage 
from blinkit_cleaned
group by outlet_type 
order by total_revenue_per_outlet desc

-- Which outlet size generates the most sales
select 
		outlet_size,
		sum(sales) as revenue_per_outletsize,
		concat(round(sum(sales)*100.0/sum(sum(sales)) over(),2),'%') as percentage 
from blinkit_cleaned
group by outlet_size
order by revenue_per_outletsize desc

--8 Which location is the strongest 
select 
		outlet_location_type,
		sum(sales) as location_type_revenue ,
		concat(round(sum(sales)*100.0/sum(sum(sales)) over(),2),'%') as percentage
from blinkit_cleaned
group by outlet_location_type
order by location_type_revenue desc

/*Fat content Analysis */

--9 Do Low Fat items sell more than Regular items
select 
		item_fat_content,
		sum(sales) as fat_content_sales,
		concat(round(sum(sales)*100.0/ sum(sum(sales)) over(),2),'%') as percentage
from blinkit_cleaned
group by item_fat_content
order by fat_content_sales desc 

--10 Which outlet sells more LF products
select outlet_type,count(*) low_fat_count,sum(sales) as low_fat_sales from blinkit_cleaned
where item_fat_content = 'Low Fat'
group by outlet_type 
order by low_fat_sales desc
limit 5

/*RATING ANALYSIS*/

--11 Which outlet type has highest rating 
select 
		outlet_type,
		round(avg(rating),2) as avg_rating 
from blinkit_cleaned
group by outlet_type
order by avg_rating desc;

--12 Does higher rating = higher sales 
select 
    rating,
    count(*) as total_orders,
    sum(sales) as total_sales,
    round(avg(sales),2) as avg_sales
from blinkit_cleaned
group by rating
order by rating;

/* COMBINED ANALYSIS */

--13 Which outlet type and item type combination perform best 
select 
		outlet_type ,
		item_type,
		sum(sales) as revenue 
from blinkit_cleaned
group by outlet_type,item_type
order by revenue desc
limit 5

--14 Which location and outlet type gives highest sales 
select 
		outlet_type,
		outlet_location_type,
		sum(sales) as highest_sales 
from blinkit_cleaned
group by outlet_type,outlet_location_type
order by highest_sales desc
limit 5 

/*OUTLIER DETECTION*/

--15 Are there extremely high or low sales value

with quartiles as 
(
select 
		percentile_cont(0.25) within group (order by sales) as q1,
		percentile_cont(0.75) within group (order by sales) as q3
from blinkit_cleaned
),
bounds as 
(
select 
		q1,
		q3,
		q3-q1 as iqr,
		q1-1.5*(q3-q1) as lower_bound,
		q3 + 1.5*(q3-q1) as upper_bound
from quartiles
)
select * from blinkit_cleaned b
cross join bounds bd
where b.sales < bd.lower_bound
	or b.sales > bd.upper_bound 

--Checking Bounds

with quartiles as (
    select 
        percentile_cont(0.25) within group (order by sales) as q1,
        percentile_cont(0.75) within group (order by sales) as q3
    from blinkit_cleaned
)
select 
    q1,
    q3,
    (q3 - q1) as iqr,
    q1 - 1.5*(q3 - q1) as lower_bound,
    q3 + 1.5*(q3 - q1) as upper_bound
from quartiles;

--Actual Data

select max(sales) as max_sales,min(sales) as min_sales from blinkit_cleaned

-- Clean Summary Query 
SELECT 
    'Total Rows' AS metric, 
    COUNT(*)::TEXT AS value 
FROM blinkit_cleaned

UNION ALL
SELECT 
    'Unique Items', 
    COUNT(DISTINCT item_id)::TEXT 
FROM blinkit_cleaned

UNION ALL
SELECT 
    'Total Sales', 
    ROUND(SUM(sales), 2)::TEXT 
FROM blinkit_cleaned

UNION ALL
SELECT 
    'Avg Rating', 
    ROUND(AVG(rating), 2)::TEXT 
FROM blinkit_cleaned

UNION ALL
SELECT 
    'Low Fat Sales %', 
    ROUND(100.0 * SUM(CASE WHEN item_fat_content = 'Low Fat' THEN sales ELSE 0 END) 
          / NULLIF(SUM(sales), 0), 2)::TEXT || '%' 
FROM blinkit_cleaned;

SELECT 
    SUM(CASE WHEN item_weight IS NULL THEN 1 ELSE 0 END) AS remaining_null_weight,
    COUNT(*) AS total_rows
FROM blinkit_cleaned;
