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
## 📊 Olist E-Commerce Project – Business Insights

### A. Payment & Transaction Analysis
- **Credit cards** dominate payments (**74% of orders**) with the **highest average order value ($146.91)** → preferred for higher-ticket purchases.  
- **Boleto payments** (Brazilian bank slips) make up ~19% of orders but take the **longest to confirm (33 hours)**, delaying fulfillment.  

### B. Customer Behavior & Retention
- **Customer acquisition** grew sharply from 2017, peaking in **Nov 2017 (7,544 new customers)** and sustaining growth until mid-2018 before dropping after Sep 2018.  
- **Time between first and second purchases** is long (**500+ days** for many repeat customers), suggesting **weak retention & engagement**.  
- **Top lifetime value (LTV) customers** can generate **thousands of dollars per month** (e.g., ~$13.6K in Sep 2017), though these are **rare outliers**.  


### C. Cart Size & Order Composition
- **Average cart value per order:** $160.78.  
- **Average items per order:** ~1.14 → most customers buy **only a single item**, showing low bundling/cross-selling.  
- **Cart value by region:**  
  - Higher in **Paraíba (PB), Acre (AC), and Amapá (AP)** ($240–260).  
  - Lower in **São Paulo (SP)** despite higher order volume.  


### D. Seller Performance
- **Top 10 sellers** generate revenues of **$130K–$228K**, but **review scores vary (3.3 – 4.3)** → **sales ≠ customer satisfaction**.  
- **Seller location impacts logistics:**  
  - **Ceará (CE), Amazonas (AM):** longest delivery delays (~19 days).  
  - **São Paulo (SP), Rio de Janeiro (RJ):** faster (~8–9 days).  
- **Freight costs are uneven:**  
  - **Rondônia (RO):** $50.91 per order (very high).  
  - **São Paulo (SP):** ~$21 (much lower).  


### E. Delivery & Review Impact
- **Severe delivery delays (100+ days)** → strongly linked to **low reviews (1–2 stars)**.  
- **Moderate delays** can still yield **mixed reviews** (some 5 stars), showing **product quality sometimes offsets delivery issues**.  


### F. Product & Regional Insights
- **São Paulo (SP)** dominates nearly every product category, leading revenue across home goods, beauty, gifts, sports, and electronics.  
- **Top categories by revenue (SP):**  
  1. Bed, bath & table → **~$556K**  
  2. Beauty & health → **~$520K**  
  3. Gifts & watches → **~$463K**  
  4. Sports & leisure → **~$442K**  
  5. Electronics accessories → **~$397K**  


### ✅ Overall Summary
Olist’s marketplace is **credit-card driven**, highly concentrated in **São Paulo**, with **low repeat purchase rates** and **logistics challenges** in remote states.  

**Opportunities for growth:**  
- Improve **customer retention** & encourage repeat purchases.  
- Reduce **delivery delays** and optimize **freight logistics**.  
- Encourage **multi-item orders** via bundling & promotions.  
- Balance seller focus between **high sales** and **customer satisfaction**.  


--- 
## 📈 Key Business Questions & Visualizations

### 1. What is average delivery duration by weekday?
![Chart](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/analytical_plots/Deliveries_and_Avg_Delivery_Days_by_Weekday.png)


### 2. Which days of the week have the highest average order value and order count?
![Chart](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/analytical_plots/Revenue_Orders_and_Avg_Order_Value_by_Weekday.png)


### 3. How does the seller’s location (state/region) affect the average delivery delay?
![Chart](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/analytical_plots/Delivery_Delay_Metrics_by_Seller_State.png)


### 4. How installments correlate with delivery time?
![Chart](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/analytical_plots/Order_Count_and_Average_Delivery_Days_by_Installments.png)


### 5. What is seller location impact on freight cost per order?
![Chart](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/analytical_plots/Orders_Freight_and_Total_per_Order_by_Seller_State.png)


### 6. Payment Behavior
![Chart](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/analytical_plots/Payment_Type_Analysis.png)

---

## 📊 Dashboard
A **Tableau Dashboard** was built for interactive visualization.  
Key highlights:
- **Revenue trends over time**  
- **Geographic distribution of customers & sellers**  
- **Category-level performance**  
[Dashboard link](https://public.tableau.com/views/OlistE-commerce_17569615225770/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
 
![Dashboard Placeholder](https://github.com/ghazalayobi/data-projects/blob/main/olist-ecommerce/docs/olist_ecommerce_dashboard_Ghazal_Ayobi.png)

---

## 🔮 Future Enhancements
- Add **machine learning models** for demand forecasting.  

---

## 🏆 Project Takeaways
This project demonstrates:
- **Data engineering pipeline skills** (bronze/silver/gold).  
- **SQL cleaning & transformation** (with stored procedures).  
- **Database design & ERD modeling**.  
- **Business intelligence** through advanced analytics and dashboards.  
- Ability to **scale and automate** data workflows.  



---
