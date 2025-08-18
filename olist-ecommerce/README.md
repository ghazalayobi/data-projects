# Olist E-Commerce Data Engineering & Analytics Project

## 📌 Project Overview
This project demonstrates an **end-to-end data engineering and analytics pipeline** using the **Olist E-Commerce dataset**.  
The work includes **data ingestion, cleaning, transformation, pipeline orchestration, database design, stored procedures, and advanced SQL analytics**, culminating in interactive dashboards and insights.  

The goal is to use **data analysis skills**, and **data engineering practices** to build a robust pipeline, handling messy data, and ensuring scalability.

---

## 🏗️ Data Pipeline Architecture
The project was structured as a complete data engineering pipeline:

1. **Data Ingestion**  
   - Raw Olist dataset ingested into the `bronze` layer.
   - Stored in CSV format and imported into PostgreSQL (via DBeaver/SQL scripts).

2. **Data Cleaning & Transformation**  
   - Cleaning in `silver` layer:
     - Removed nulls and duplicates.  
     - Standardized inconsistent date/time formats.  
     - Normalized categorical values (e.g., state codes, product categories).  
     - Handled outliers (e.g., extreme delivery times).  
   - Implemented **SQL scripts + stored procedures** for automated cleaning.

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
