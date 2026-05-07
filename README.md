# Blinkit Sales Analysis Dashboard

![Blinkit Sales Dashboard](dashboard.png)

**End-to-End SQL Analysis** of Blinkit (India's Last Minute Delivery App) sales data.

---

## 📊 Project Overview

This project involves **data cleaning, transformation, and exploratory data analysis (EDA)** on Blinkit sales dataset using PostgreSQL. The analysis provides deep business insights into sales performance, outlet efficiency, product categories, and customer ratings.

### Key Business Insights
- **Total Sales**: ₹1.20 Million
- **Average Sales per Transaction**: ₹140.99
- **Average Rating**: 3.97
- **Total Unique Items**: 9,000
- **Top Outlet**: Supermarket Type 1 (₹0.79M revenue)
- **Low Fat Products**: Contribute **64.6%** of total sales
- **Top Performing Category**: Fruits & Vegetables

---

## 🛠 Technologies Used

- **Database**: PostgreSQL
- **SQL Features**:
  - Window Functions
  - Common Table Expressions (CTEs)
  - Data Imputation
  - Percentile Analysis (IQR Method)
  - Advanced Aggregations

---

## 📁 Project Structure
blinkit-sales-analysis/
├── README.md                 # Project documentation
├── schema.sql                # Table creation & Data Cleaning
├── eda_queries.sql           # All Exploratory Data Analysis queries
├── dashboard.png             # Final Blinkit Sales Dashboard
└── .gitignore
text---

## 🚀 How to Run

1. **Setup the Database**
   ```bash
   psql -U your_username -d your_database -f schema.sql

Run Analysis QueriesBashpsql -U your_username -d your_database -f eda_queries.sql


📋 Analyses Covered
1. Overall Performance

Total Sales, Average Sales, Total Unique Items

2. Sales by Category

Top 5 and Bottom 5 performing item types

3. Outlet Performance

Revenue by Outlet Type, Size, and Location Tier

4. Fat Content Analysis

Low Fat vs Regular products performance

5. Rating Analysis

Average ratings by outlet type
Correlation between rating and sales

6. Combined & Advanced Analysis

Best performing Outlet + Item Type combinations
Outlier Detection using IQR method
Derived Metrics (Outlet Age, Visibility Category, Sales-Rating Score)


Key SQL Techniques Demonstrated

Missing value imputation using Window Functions
Data standardization (Fat Content)
Percentage contribution calculations
Outlier detection with statistical methods
Multi-dimensional analysis (Group By multiple columns)


Future Scope

Building interactive dashboard using Power BI / Tableau
Python automation (Pandas + SQLAlchemy)
Sales forecasting model
Customer segmentation


Project developed as part of Data Analysis Portfolio
