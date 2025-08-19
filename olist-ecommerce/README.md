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
   -  **Silver Layer Loading Features** 
      - Full refresh using `TRUNCATE` for each table.  
      - Progress tracking and execution duration logging via `RAISE NOTICE`.  
      - Error handling for each table to prevent pipeline failures.
   - **Key Script**:
      - [Silver Table Creation](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/scripts/03_table_creation_silver.sql)
      - [Test and Checks Script](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/scripts/04_test_script_bronze.sql)
      - [Silver Data Load Procedure](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/scripts/05_load_silver.sql)  

3. **Enrichment & Business Logic**  
   - In `gold` layer:
     - Created fact and dimension tables.  
     - Derived KPIs: revenue, repeat customers, delivery delays, etc.  
     - Built star schema for efficient querying.
   - **Key Script**:
      - [Gold Layer Dimensions and Facts](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/scripts/07_load_gold_layer.sql)

4. **Orchestration & Pipeline Management**  
   - Developed a reproducible pipeline using SQL scripts.  
   - Structured into:
     - **Bronze** → Raw ingestion  
     - **Silver** → Cleaned, conformed data  
     - **Gold** → Analytics-ready warehouse layer  

---

## 📊 Data Architecture & Diagrams

### Entity Relationship Diagram (ERD)
![ERD](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/ERD.png)

### Data Architecture Diagram
![Data Architecture](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/data_architecture_olist.drawio.png)

### Data Flow Diagram
*(Insert DFD here)*  
![Data Flow Placeholder](path/to/dfd.png)

---
## Key Insights from EDA 

### 1. Orders & Sales Overview  
- Dataset covers **2016-09-04 to 2018-10-17** with **97.02% orders delivered**.  
- No duplicate `order_id` exists.  
- Sales peaked in **Nov 2017 ($1M+)** and **Apr–May 2018 (~$996K)**, showing strong **seasonal demand**.  
- Order volumes are highest on **Mondays (16,196)** and lowest on **Saturdays (10,887)**.  
- **Seasonality:** peak order months are **August, May, July**, while **September, October, December** see dips.  


### 2. Pricing & Freight Dynamics  
- **Order item price range:** $0.85 – $6,735 (median $74.99).  
- **Freight value distribution:** Avg $20.03, median $16.27, with most orders in the **$10–50 range (92K orders)**.  
- Correlation between **freight cost and order price** is **moderately positive (0.41)**.  
- A small group of sellers incur **very high freight costs (> $150 per order)**.  


### 3. Delivery Performance  
- **Overall delivery times:** median **10 days**, avg **12.5 days**, ranging from **12 hours to ~7 months**.  
- Delivery efficiency **improved over time**, from ~24 days (Sep 2016) to ~7 days (Aug 2018).  
- **Regional patterns:**  
  - Fastest: **SP (8.3 days)**  
  - Slowest: **RR (29 days)**  
- **Category patterns:**  
  - Fastest: **Arts & Craftsmanship (5.3 days)**, **La Cuisine (7 days)**  
  - Slowest: **Office furniture (15.3 days)**, **Security & Services (15 days)**  
- Some cities show **suspiciously fast deliveries → possible data discrepancies**.  


### 4. Customer Insights  
- Total customers: **96,096**  
- Repeat buyers: **2,997 (~3.1%) → low loyalty**  
- Customer concentration: majority in **SP, RJ, MG** (same as top sales states).  


### 5. Seller Insights  
- Sellers concentrated in **SP, PR, MG**.  
- Top 10 sellers generate **$229K+** (leading seller) with ~1,132 orders.  
- Avg freight for top sellers ranges **$16–38**, below the extreme freight outliers (> $150).  


### 6. Product Categories & Reviews  
- **Highest-rated categories:** CDs/DVDs/Musicals (4.64), Children’s Clothing (4.50), Books (4.45).  
- **Lowest-rated categories:** Security & Services (2.50), Diapers & Hygiene (3.26).  
- **Review & delivery link:** Faster deliveries → higher ratings.  
  - 5-star avg delivery: **9.8 days**  
  - 1-star avg delivery: **12.4 days**  
- **Review & pricing link:** Lower ratings are associated with slightly higher order prices:  
  - Score 1 → $127.56  
  - Score 5 → $121.42  


### 7. Payments & Order Value  
- **Payment split:** Installments 51.46%, single payments 49.33%.  
- **Most common:** 1 installment (52K+ orders).  
- **Installments linked to higher order values:**  
  - 1 installment → $112 avg  
  - 10 installments → $415 avg  
  - 20 installments → $616 avg  


## 🔑 Takeaways  
1. **Delivery time strongly influences customer satisfaction** → faster delivery = higher reviews.  
2. **Regional and category disparities** exist in delivery speed, suggesting logistics optimization opportunities.  
3. **Customer loyalty is low (~3%)**, despite high delivery rates, meaning retention strategies are needed.  
4. **Installments drive higher-value purchases**, indicating a key lever for revenue growth.  
5. **Freight cost correlates with order price**, but some sellers have unusually high costs worth auditing.  
6. **Seasonality and weekdays impact sales volume**, with Monday and summer months as sales peaks.  



## Some Visualizations for EDA


- **Delivery Time Distribution**  
![delivery_time_distribution](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/EDA_plot/delivery_time_distribution.png) 

- **Orders Per Month**  
![orders_per_month](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/EDA_plot/orders_per_month.png)  

- **Payment Type**  
![payment_type](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/EDA_plot/payment_type_distribution.png)  

- **Average Review Score by Category**  
![Review Score by Category](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/EDA_plot/top_categories_by_review_score.png)  

- **Top Categories by Sales**  
![Top cATEGORIES](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/EDA_plot/top_categories_by_sales.png)  

- **Sellers with Highest Sales**  
![Top Sellers](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/EDA_plot/top_sellers_by_sales.png) 
  

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
