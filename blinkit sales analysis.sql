-- =============================================
-- BLINKIT SALES ANALYSIS - EDA QUERIES
-- =============================================
-- Author: Anju krishna E 
-- Date: May 2026
-- Description: Exploratory Data Analysis for Blinkit Sales Dashboard

/* =============================================
   OVERALL PERFORMANCE
   ============================================= */

-- 1. Total Sales
SELECT SUM(sales) AS total_sales 
FROM blinkit_cleaned;

-- 2. Average Sales per Item Type
SELECT 
    item_type,
    ROUND(AVG(sales), 2) AS avg_sales_per_item
FROM blinkit_cleaned
GROUP BY item_type
ORDER BY avg_sales_per_item DESC;

-- 3. Total Unique Items
SELECT COUNT(DISTINCT item_id) AS no_of_items 
FROM blinkit_cleaned;

/* =============================================
   SALES BY CATEGORY
   ============================================= */

-- 4. Top 5 Item Categories by Revenue + Contribution %
SELECT 
    item_type,
    SUM(sales) AS total_sale,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER(), 2) || '%' AS contribution_percentage
FROM blinkit_cleaned
GROUP BY item_type
ORDER BY total_sale DESC
LIMIT 5;

-- 5. Bottom 5 Item Categories by Revenue
SELECT 
    item_type,
    COUNT(*) AS total_transactions,
    SUM(sales) AS total_sales,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER(), 2) || '%' AS contribution_percentage
FROM blinkit_cleaned
GROUP BY item_type
ORDER BY total_sales ASC
LIMIT 5;

/* =============================================
   OUTLET PERFORMANCE
   ============================================= */

-- 6. Revenue by Outlet Type
SELECT 
    outlet_type,
    SUM(sales) AS total_revenue,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER(), 2) || '%' AS percentage_contribution
FROM blinkit_cleaned
GROUP BY outlet_type
ORDER BY total_revenue DESC;

-- 7. Revenue by Outlet Size
SELECT 
    outlet_size,
    SUM(sales) AS total_revenue,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER(), 2) || '%' AS percentage_contribution
FROM blinkit_cleaned
GROUP BY outlet_size
ORDER BY total_revenue DESC;

-- 8. Revenue by Outlet Location Type
SELECT 
    outlet_location_type,
    SUM(sales) AS total_revenue,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER(), 2) || '%' AS percentage_contribution
FROM blinkit_cleaned
GROUP BY outlet_location_type
ORDER BY total_revenue DESC;

/* =============================================
   FAT CONTENT ANALYSIS
   ============================================= */

-- 9. Sales by Fat Content
SELECT 
    item_fat_content,
    SUM(sales) AS total_sales,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER(), 2) || '%' AS percentage
FROM blinkit_cleaned
GROUP BY item_fat_content
ORDER BY total_sales DESC;

-- 10. Low Fat Products Performance by Outlet
SELECT 
    outlet_type,
    COUNT(*) AS low_fat_count,
    SUM(sales) AS low_fat_sales,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER(), 2) || '%' AS percentage
FROM blinkit_cleaned
WHERE item_fat_content = 'Low Fat'
GROUP BY outlet_type
ORDER BY low_fat_sales DESC;

/* =============================================
   RATING ANALYSIS
   ============================================= */

-- 11. Average Rating by Outlet Type
SELECT 
    outlet_type,
    ROUND(AVG(rating), 2) AS avg_rating
FROM blinkit_cleaned
GROUP BY outlet_type
ORDER BY avg_rating DESC;

-- 12. Sales Performance by Rating
SELECT 
    rating,
    COUNT(*) AS total_transactions,
    SUM(sales) AS total_sales,
    ROUND(AVG(sales), 2) AS avg_sales_per_transaction
FROM blinkit_cleaned
GROUP BY rating
ORDER BY rating DESC;

/* =============================================
   COMBINED ANALYSIS
   ============================================= */

-- 13. Top Outlet Type + Item Type Combinations
SELECT 
    outlet_type,
    item_type,
    SUM(sales) AS total_revenue
FROM blinkit_cleaned
GROUP BY outlet_type, item_type
ORDER BY total_revenue DESC
LIMIT 5;

-- 14. Top Location + Outlet Type Combinations
SELECT 
    outlet_location_type,
    outlet_type,
    SUM(sales) AS total_revenue
FROM blinkit_cleaned
GROUP BY outlet_location_type, outlet_type
ORDER BY total_revenue DESC
LIMIT 5;

/* =============================================
   OUTLIER DETECTION & SUMMARY
   ============================================= */

-- 15. Sales Outliers (Using IQR Method)
WITH quartiles AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY sales) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY sales) AS q3
    FROM blinkit_cleaned
),
bounds AS (
    SELECT 
        q1, q3,
        q3 - q1 AS iqr,
        q1 - 1.5 * (q3 - q1) AS lower_bound,
        q3 + 1.5 * (q3 - q1) AS upper_bound
    FROM quartiles
)
SELECT 
    b.*,
    bd.lower_bound,
    bd.upper_bound
FROM blinkit_cleaned b
CROSS JOIN bounds bd
WHERE b.sales < bd.lower_bound 
   OR b.sales > bd.upper_bound
ORDER BY b.sales DESC;

-- 16. Sales Bounds Summary
WITH quartiles AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY sales) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY sales) AS q3
    FROM blinkit_cleaned
)
SELECT 
    q1,
    q3,
    (q3 - q1) AS iqr,
    q1 - 1.5*(q3 - q1) AS lower_bound,
    q3 + 1.5*(q3 - q1) AS upper_bound
FROM quartiles;

-- 17. Project Summary (Key Metrics)
SELECT 'Total Rows' AS metric, COUNT(*)::TEXT AS value FROM blinkit_cleaned
UNION ALL
SELECT 'Unique Items', COUNT(DISTINCT item_id)::TEXT FROM blinkit_cleaned
UNION ALL
SELECT 'Total Sales (₹)', ROUND(SUM(sales), 2)::TEXT FROM blinkit_cleaned
UNION ALL
SELECT 'Avg Rating', ROUND(AVG(rating), 2)::TEXT FROM blinkit_cleaned
UNION ALL
SELECT 'Low Fat Sales %', 
       ROUND(100.0 * SUM(CASE WHEN item_fat_content = 'Low Fat' THEN sales ELSE 0 END) 
             / NULLIF(SUM(sales), 0), 2)::TEXT || '%' 
FROM blinkit_cleaned;
