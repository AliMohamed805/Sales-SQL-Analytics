# 🟡 Sales SQL Business Intelligence Project

This project is a full-scale **business intelligence solution** built entirely using SQL. It focuses on analyzing a retail sales dataset to extract valuable insights across time, customer behavior, product performance, and revenue growth. The project demonstrates advanced SQL techniques used in real-world data analytics.

---

## 📦 Dataset Overview

The database follows a typical star schema and contains:

- `gold_fact_sales`: The main transaction table with order numbers, dates, sales amounts, product keys, and customer keys.
- `gold_dim_products`: Product metadata including name, category, subcategory, and cost.
- `gold_dim_customers`: Customer demographics like full name and birthdate.

---

## 📊 Project Goals

✅ Clean and prepare data for analysis  
✅ Perform temporal analysis (monthly, quarterly, yearly)  
✅ Calculate cumulative trends and moving averages  
✅ Evaluate product and customer performance  
✅ Segment customers and products based on business logic  
✅ Build reusable reporting views for business stakeholders

---

## 🔧 Tools & Technologies

- **Database**: PostgreSQL 14+
- **Language**: SQL (CTEs, window functions, aggregates, date functions)
- **Platform**: Works in pgAdmin, DBeaver, Azure Data Studio, or any PostgreSQL client

---

## 🔍 Analytical Modules

### 1. 🧹 **Data Cleaning**
- Identify and fix missing `order_date` by using `shipping_date - 7 days`
- Validate date ranges and ensure type casting for numeric fields

---

### 2. 📆 **Change Over Time Analysis**
- Total Sales, Orders, and Customers over:
  - Year (`DATE_PART('year', ...)`)
  - Month (`DATE_PART('month', ...)`)
  - Year-Month hierarchy
  - Quarter (`date_trunc('quarter', ...)`)

> Helps visualize seasonality, growth trends, and year-over-year comparisons.

---

### 3. 📈 **Cumulative & Moving Average Analysis**
- Running totals using `SUM(...) OVER (ORDER BY date)`
- Moving averages using `AVG(...) OVER (...)`
- Visualize how sales accumulate over time
- Track stability or volatility in revenue

---

### 4. 🏅 **Performance Analysis by Product**
- Group products by year and compute:
  - Sales trends
  - Sales performance compared to product average
  - Year-over-year sales changes (lag comparison)
- Assign product performance labels:
  - `Above Average`, `Below Average`, `No Change`

---

### 5. 🧩 **Part-to-Whole Analysis**
- Breakdown total sales by **category**
- Calculate each category’s contribution to overall revenue
- Visualized using percentage calculations

---

### 6. 🔍 **Customer Segmentation**
Segments customers based on:

- **Lifetime Value**: Order activity duration in months
- **Total Sales**:
  - VIP: Lifetime ≥ 12 months and Sales > 5000
  - Regular: Lifetime ≥ 12 months and Sales ≤ 5000
  - New: Lifetime < 12 months

> Useful for targeted marketing and retention strategies.

---

### 7. 🧮 **Product Segmentation**
Group products based on cost:

- `Below 100`
- `100 - 500`
- `500 - 1000`
- `Above 1000`

Segment products as:

- `High-Performer`: Sales > 50,000
- `Mid-Range`: Sales 10,000–50,000
- `Low-Performer`: Sales < 10,000

---

## 📊 Reports

### 📄 `gold_customer_report` (SQL View)

- Age & age segment
- Customer lifetime (in months)
- Segment: `VIP`, `Regular`, `New`
- Total orders, products, sales, quantities
- Average order value & monthly spending

### 📄 `gold_product_report` (SQL View)

- Category, subcategory, cost
- Sales lifespan in months
- Product performance segment
- Recency of last sale
- Average selling price
- Avg monthly revenue

---

## 🧠 Business Use Cases

- 📈 Identify high-performing products to invest in
- 🎯 Segment and target VIP customers
- 🛍️ Monitor seasonal revenue trends
- 💰 Compare product price bands and impact on revenue
- 🧬 Support data-driven decisions without BI tools
