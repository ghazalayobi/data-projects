# Olist E-Commerce Data Engineering & Analytics Project

## 📌 Project Overview
This project demonstrates an **end-to-end data engineering and analytics pipeline** using the **Olist E-Commerce dataset**.  
The work includes **data ingestion, cleaning, transformation, pipeline orchestration, database design, stored procedures, and advanced SQL analytics**, culminating in interactive dashboards and insights.  

The goal is to use **data analysis skills**, and **data engineering practices** to build a robust pipeline, handling messy data, and ensuring scalability.

---

## 🏗️ Data Pipeline Architecture
The project was structured as a complete data engineering pipeline:

1. **Data Ingestion**  
   - Built the **`bronze` layer** as the raw data foundation of the pipeline.  
   - Data stored in **CSV format** and ingested into **PostgreSQL** using DBeaver/SQL scripts.  
   - **Schema-First Approach**  
     - Created dedicated `bronze` tables for each Olist entity (`customers`, `orders`, `products`, `sellers`, `geolocation`, `order_items`, `payments`, `reviews`, and `category_translation`).  
     - Enforced **primary keys** where available (e.g., `customer_id`, `order_id`) and composite keys for transactional data (e.g., `(order_id, order_item_id)`).  
     - Ensured correct data types (`VARCHAR`, `NUMERIC`, `DECIMAL`, `TIMESTAMP`) to preserve raw integrity.  
   - **Automated Data Loading with Stored Procedure**  
     - Developed **`bronze.load_bronze()`** procedure to automate ingestion:  
       - **TRUNCATE** each table for a full refresh.  
       - **COPY** data from CSV into PostgreSQL tables.  
       - Logged timings with `RAISE NOTICE` to monitor performance.  
       - Implemented **exception handling** with `RAISE WARNING` for robust error capture.  
   - **Example: Data Load (Customers Table)**  
     ```sql
     TRUNCATE TABLE bronze.olist_customers_dataset CASCADE;
     COPY bronze.olist_customers_dataset
     FROM '/path/to/olist_customers_dataset.csv'
     DELIMITER ','
     CSV HEADER;
     ```  
   - **Execution**: Data ingestion is triggered with a single command:  
     ```sql
     CALL bronze.load_bronze();
     ```  
   - **Key Scripts**:  
     - [Bronze Table Creation](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/scripts/01_table_creation_bronze.sql)  
     - [Bronze Data Load Procedure](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/scripts/02_load_data_bronze.sql)  

2. **Data Cleaning & Transformation**  
   - Implemented in the `silver` layer, where raw ingested data is standardized, validated, and structured for analytics.  
   - **Schema Design**  
     - Defined `silver` tables with **primary/foreign keys, audit columns (`dwh_create_date`), and constraints** to ensure integrity.  
     - Modeled entities such as `customers`, `orders`, `products`, `sellers`, `order_items`, `payments`, and `reviews`.  
   - **Key Cleaning Rules Applied**  
     - **City/State Normalization**: Corrected abbreviations (`sp → sao paulo`, `rj → rio de janeiro`, etc.), removed special characters, and standardized casing using `unaccent()` and regex.  
     - **ZIP Code Standardization**: Ensured consistent **5-digit ZIP codes** across customers, sellers, and geolocations.  
     - **Referential Integrity Checks**:  
       - Orders linked only to valid customers.  
       - Items validated against existing products and sellers.  
       - Reviews restricted to unique orders (latest review per order kept).  
     - **Outlier & Quality Handling**:  
       - Dropped rows with invalid/null IDs.  
       - Removed negative/zero prices in `order_items` and invalid payments.  
       - Labeled inconsistent orders with a `row_flag` (e.g., canceled orders that still had delivery timestamps).  
     - **Derived Columns**: Calculated delivery time intervals (`delivered_customer_date - purchase_timestamp`) and flagged invalid timelines (e.g., delivery before approval).  
   - **Automated Pipeline with Stored Procedure**  
     - Created a master procedure: **`silver.load_silver()`**, which:  
       - Truncates and reloads each table (full refresh).  
       - Applies cleaning/standardization logic inline during inserts.  
       - Tracks performance using `RAISE NOTICE` timings.  
       - Implements **exception handling** to capture and log table-specific errors.  
   - **Example: City Normalization (Geolocation & Customers)**  
     ```sql
     CASE
         WHEN lower(trim(city)) = 'sp' AND state = 'SP' THEN 'sao paulo'
         WHEN lower(trim(city)) = 'rj' AND state = 'RJ' THEN 'rio de janeiro'
         WHEN lower(trim(city)) = 'bh' AND state = 'MG' THEN 'belo horizonte'
         WHEN regexp_replace(city, '[\\/].*$', '') ~ '^[0-9\s]+$' THEN 'unknown'
         WHEN lower(unaccent(trim(city))) = '4o centenario' THEN '4º centenario'
         ELSE unaccent(
             regexp_replace(
                 regexp_replace(
                     lower(trim(both from regexp_replace(city, '[\\/].*$', ''))),
                     '[^a-z\s]', '',
                     'g'
                 ),
                 '\s+', ' ',
                 'g'
             )
         )
     END AS city
     ```  
   - **Key Script**: [`silver.load_silver()`](#) – Orchestrates the full transformation pipeline.  

3. **Enrichment & Business Logic**  
   - In `gold` layer:
     - Created fact and dimension tables.  
     - Derived KPIs: revenue, repeat customers, delivery delays, etc.  
     - Built star schema for efficient querying.

4. **Orchestration & Pipeline Management**  
   - Developed a reproducible pipeline using SQL scripts.  
   - Structured into:
     - **Bronze** → Raw ingestion  
     - **Silver** → Cleaned, conformed data  
     - **Gold** → Analytics-ready warehouse layer  

---

## 📊 Data Architecture & Diagrams

### Entity Relationship Diagram (ERD)
*(Insert ERD here)*  
![ERD Placeholder](path/to/erd.png)

### Data Architecture Diagram
*(Insert overall architecture diagram here)*  
![Architecture Placeholder](path/to/architecture.png)

### Data Flow Diagram
*(Insert DFD here)*  
![Data Flow Placeholder](path/to/dfd.png)

---

## 🧹 Data Cleaning Process
The cleaning process was implemented with **SQL queries and stored procedures**, ensuring automation and reproducibility.

- Removed invalid rows where **IDs were null**.  
- Handled **duplicate reviews** by keeping the latest timestamp.  
- Fixed **missing product categories** with `"unknown"`.  
- Converted **text-based dates** to standardized SQL `TIMESTAMP`.  
- Ensured **referential integrity** between orders, payments, and reviews.

> 🔑 Example: A stored procedure to clean `olist_order_reviews_dataset` handled duplicate reviews and null entries in one execution.

---

## ⚙️ Stored Procedures & Automation
To demonstrate advanced SQL engineering, multiple **stored procedures** were created:

- **`sp_clean_reviews`** → Cleans review dataset.  
- **`sp_load_orders`** → Loads and validates orders into the silver layer.  
- **`sp_generate_kpis`** → Aggregates metrics (revenue, delivery SLA, NPS-like scores).  

This modular approach ensures that the **pipeline can be re-run automatically** without re-writing queries.

---

## 📈 Key Business Questions & Visualizations

### 1. Which categories generate the highest revenue?
*(Insert chart here)*  
![Chart Placeholder](path/to/chart1.png)

---

### 2. What are the top states and cities by order volume?
*(Insert chart here)*  
![Chart Placeholder](path/to/chart2.png)

---

### 3. How do delivery times compare to estimated delivery times?
*(Insert chart here)*  
![Chart Placeholder](path/to/chart3.png)

---

### 4. Customer Review Insights
- Average rating by category.  
- Review distribution over time.  

*(Insert chart here)*  
![Chart Placeholder](path/to/chart4.png)

---

### 5. Repeat Customers & Retention
- Number of first-time vs returning customers.  
- Revenue contribution from repeat buyers.  

*(Insert chart here)*  
![Chart Placeholder](path/to/chart5.png)

---

### 6. Payment Behavior
- Popular payment methods (credit card, boleto, etc.).  
- Installment patterns across customers.  

*(Insert chart here)*  
![Chart Placeholder](path/to/chart6.png)

---

## 📊 Dashboard
A **Tableau/Power BI Dashboard** was built for interactive visualization.  
Key highlights:
- **Revenue trends over time**  
- **Geographic distribution of customers & sellers**  
- **Category-level performance**  
- **Delivery SLA tracking**  

*(Insert screenshot of dashboard here)*  
![Dashboard Placeholder](path/to/dashboard.png)

---

## 🚀 Pipeline Demonstration
The project pipeline can be summarized as:

- **Raw Layer (Bronze):** Load CSV data → PostgreSQL.  
- **Cleaning Layer (Silver):** Automated stored procedures handle cleaning and transformations.  
- **Analytics Layer (Gold):** Optimized schema for BI dashboards.  

*(Insert pipeline diagram here)*  
![Pipeline Placeholder](path/to/pipeline.png)

---

## 🔮 Future Enhancements
- Add **machine learning models** for demand forecasting.  
- Deploy dashboards to **Tableau Public** for sharing.  

---

## 🏆 Project Takeaways
This project demonstrates:
- **Data engineering pipeline skills** (bronze/silver/gold).  
- **SQL cleaning & transformation** (with stored procedures).  
- **Database design & ERD modeling**.  
- **Business intelligence** through advanced analytics and dashboards.  
- Ability to **scale and automate** data workflows.  



---
