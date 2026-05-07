-- =============================================
-- BLINKIT SALES ANALYSIS - SCHEMA & DATA CLEANING
-- =============================================
-- Author: Anju krishna E
-- Date: May 2026
-- Description: Table creation and data cleaning for Blinkit Sales Dashboard

-- 1. Create Original Table
CREATE TABLE IF NOT EXISTS blinkit_sales (
    item_id                  VARCHAR(50),
    item_type                VARCHAR(50),
    item_fat_content         VARCHAR(20),
    item_weight              NUMERIC(10,2),
    item_visibility          NUMERIC(10,4),
    outlet_id                VARCHAR(20),
    outlet_type              VARCHAR(50),
    outlet_establishment_year INT,
    outlet_size              VARCHAR(20),
    outlet_location_type     VARCHAR(10),
    sales                    NUMERIC(10,2),
    rating                   NUMERIC(3,1)
);

-- 2. Create Cleaned Table with Proper Data Cleaning
CREATE TABLE IF NOT EXISTS blinkit_cleaned AS
SELECT
    item_id,
    item_type,
    
    -- Standardized Fat Content
    CASE
        WHEN LOWER(item_fat_content) IN ('low fat', 'lf') THEN 'Low Fat'
        WHEN LOWER(item_fat_content) IN ('regular', 'reg') THEN 'Regular'
        ELSE item_fat_content
    END AS item_fat_content,
   
    -- Impute Missing Item Weight using Average by Item Type
    COALESCE(
        item_weight,
        ROUND(AVG(item_weight) OVER (PARTITION BY item_type), 2)
    ) AS item_weight,
   
    -- Fix Item Visibility (0 values treated as missing)
    CASE
        WHEN item_visibility = 0 THEN
            ROUND(AVG(NULLIF(item_visibility, 0)) OVER (PARTITION BY item_type), 4)
        ELSE item_visibility
    END AS item_visibility,
   
    outlet_id,
    outlet_type,
    outlet_establishment_year,
    outlet_size,
    outlet_location_type,
    sales,
    rating,
   
    -- Derived Columns
    (EXTRACT(YEAR FROM CURRENT_DATE) - outlet_establishment_year) AS outlet_age_years,
    
    ROUND(sales * rating, 2) AS sales_rating_score,
    
    CASE
        WHEN item_visibility < 0.05 THEN 'Low Visibility'
        WHEN item_visibility < 0.15 THEN 'Medium Visibility'
        ELSE 'High Visibility'
    END AS visibility_category

FROM blinkit_sales;

-- =============================================
-- VALIDATION QUERIES
-- =============================================

-- Check row count and remaining nulls
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN item_weight IS NULL THEN 1 ELSE 0 END) AS remaining_null_weight,
    SUM(CASE WHEN item_visibility IS NULL THEN 1 ELSE 0 END) AS remaining_null_visibility
FROM blinkit_cleaned;

-- View sample data
SELECT * FROM blinkit_cleaned 
ORDER BY outlet_id 
LIMIT 10;

-- Final Summary
SELECT
    'Total Rows' AS metric, COUNT(*)::TEXT AS value FROM blinkit_cleaned
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
