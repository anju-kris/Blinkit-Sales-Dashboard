--BLINKIT SALES TABLE CREATION

create table blinkit_sales
(
	item_id varchar(50),
	item_type varchar(50),
	item_fat_content varchar(20),
	item_weight numeric(10,2),
	item_visibility numeric(10,4),
	outlet_id varchar(20),
	outlet_type varchar(50),
	outlet_establishment_year int,
	outlet_size varchar(20),
	outlet_location_type varchar(10),
	sales numeric(10,2),
	rating numeric(3,1)
)

-- Create FINAL cleaned table with proper imputation
CREATE TABLE blinkit_cleaned AS
SELECT 
    item_id,
    item_type,
    -- Standardized Fat Content
    CASE 
        WHEN LOWER(item_fat_content) IN ('low fat', 'lf') THEN 'Low Fat'
        WHEN LOWER(item_fat_content) IN ('regular', 'reg') THEN 'Regular'
        ELSE item_fat_content 
    END AS item_fat_content,
    
    -- Proper imputation for Item Weight (this fixes NULLs)
    COALESCE(
        item_weight, 
        ROUND(AVG(item_weight) OVER (PARTITION BY item_type), 2)
    ) AS item_weight,
    
    -- Visibility fix (0 treated as missing)
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
    
    -- Derived columns
    (EXTRACT(YEAR FROM CURRENT_DATE) - outlet_establishment_year) AS outlet_age_years,
    ROUND(sales * rating, 2) AS sales_rating_score,
    CASE 
        WHEN item_visibility < 0.05 THEN 'Low Visibility'
        WHEN item_visibility < 0.15 THEN 'Medium Visibility'
        ELSE 'High Visibility' 
    END AS visibility_category

FROM blinkit_sales;
