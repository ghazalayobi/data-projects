# Olist E-commerce Data Analysis Project

## 📌 Project Overview
This project focuses on analyzing the **Olist e-commerce dataset**, a Brazilian marketplace that connects small businesses to customers.  
The dataset contains detailed information on **orders, products, sellers, customers, reviews, and payments**, making it ideal for building a data pipeline and performing advanced SQL-based analytics.  

The project includes:
- Data cleaning & transformation (Bronze → Silver → Gold layers)
- SQL queries for **exploratory data analysis (EDA)** and **business questions**
- Visualization through Tableau dashboards
- Documentation with ERD, Data Architecture, and Data Flow diagrams

---

## 🗂️ Dataset Description
The dataset is composed of multiple tables. Below are the main ones used:

- **Customers** – customer details including location  
- **Sellers** – seller information  
- **Products** – product details such as category and dimensions  
- **Orders** – order details (status, timestamps, etc.)  
- **Order Items** – line-level information on purchased products  
- **Payments** – order payment information  
- **Reviews** – customer review scores and feedback  

---

## 🏗️ Data Architecture
This project follows a **medallion architecture** (Bronze → Silver → Gold):  

1. **Bronze Layer** – Raw imported data from Olist.  
2. **Silver Layer** – Cleaned and standardized data (duplicates removed, null handling, type corrections).  
3. **Gold Layer** – Business-ready aggregated tables for analytics and dashboards.  

📌 *Insert Data Architecture Diagram Here*  
![Data Architecture Placeholder](path/to/your/architecture-diagram.png)

---

## 🔄 Data Flow
The ETL pipeline processes data as follows:
- **Extract**: Load raw CSV files into the Bronze schema  
- **Transform**: Apply cleaning, integrity checks, and relational joins in the Silver schema  
- **Load**: Aggregate metrics into the Gold schema for analytics  

📌 *Insert Data Flow Diagram Here*  
![Data Flow Placeholder](path/to/your/data-flow-diagram.png)

---

## 🗃️ Entity Relationship Diagram (ERD)
The ERD shows the relationships across key tables: customers, sellers, orders, products, reviews, and payments.  

📌 *Insert ERD Here*  
![ERD Placeholder](path/to/your/erd.png)

---

## 🔍 Exploratory Data Analysis (EDA)
Key findings from the dataset include:  

1. **Order Distribution by Status**  
   - Most orders are delivered successfully  
   - A smaller fraction are canceled or unavailable  

   📊 *Insert Chart Placeholder*  

2. **Top Product Categories by Sales**  
   - Electronics, furniture, and beauty products dominate sales  

   📊 *Insert Chart Placeholder*  

3. **Geographical Distribution of Customers & Sellers**  
   - Customers and sellers are spread across Brazil, with concentration in São Paulo  

   📊 *Insert Chart Placeholder*  

4. **Review Score Distribution**  
   - Majority of reviews are positive (4–5 stars)  
   - Negative reviews highlight delivery delays  

   📊 *Insert Chart Placeholder*  

---

## 📈 Business Questions Answered
1. What are the **top-selling product categories**?  
   📊 *Insert Chart Placeholder*  

2. Which **states/cities contribute the most revenue**?  
   📊 *Insert Chart Placeholder*  

3. What is the **average order delivery time** vs. **promised time**?  
   📊 *Insert Chart Placeholder*  

4. How do **payment methods** vary across customers?  
   📊 *Insert Chart Placeholder*  

5. What are the **factors influencing customer satisfaction** (reviews)?  
   📊 *Insert Chart Placeholder*  

---

## 📊 Dashboard
An interactive dashboard was created in **Tableau** to visualize trends and insights.  

👉 [View Tableau Dashboard](https://dummy-link.com) *(replace with real link once published)*  

---

## ⚙️ Tech Stack
- **SQL** (Data cleaning, transformation, and analytics)  
- **PostgreSQL** (Database)  
- **Tableau Public** (Visualization)  
- **DBeaver** (SQL IDE)  

---

## 🚀 Future Work
- Add machine learning models to predict delivery delays  
- Sentiment analysis on customer review text  
- Extend dashboards with real-time streaming data  

---

## 📚 References
- [Olist Dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)  
- Olist official documentation  

---
