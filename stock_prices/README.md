# 📊 Sector-Based ETF Simulation & Market Analytics (2024–2025)

## 🧠 Project Overview

The goal of this project was to **design a custom ETF** by selecting **10 representative stocks from each of 7 key U.S. sectors**, simulate its performance over a one-year period, and compare it against major market indices: **S&P 500**, **NASDAQ Composite**, and **Dow Jones**.

Through structured querying and aggregation techniques, this project provides insights into **sector trends**, **volatility**, **event-driven impacts**, and **portfolio returns** using historical price data.

> Primary focus: uncover investment potential by applying advanced data exploration logic to equity markets.

---

## 📑 Slide‑Style Project Overview (PDF)

If you’d like a quick visual walkthrough of the project (with code snippets, dashboards, and insights),  
👉 **[View the Mini Presentation (PDF)](https://github.com/USERNAME/REPO/blob/main/assets/ETF_Project_Presentation.pdf)**

![PDF Preview](https://github.com/USERNAME/REPO/blob/main/assets/pdf_preview_image.png)

---
---

## 🗂️ Dataset Summary

- **Source**: Collected using `yfinance` Python API  
- **Date Range**: `2024-07-01` to `2025-06-30`  
- **Composition**:
  - 70 stocks: 10 from each sector (e.g., Technology, Financials, Energy, etc.)
  - 3 benchmark indices: `^GSPC`, `^IXIC`, `^DJI`

---

## 📦 Project Goal

- Build a **diversified simulated ETF** composed of 70 stocks across 7 sectors
- Measure its performance over 12 months
- Compare its return and volatility to **S&P 500**, **NASDAQ**, and **Dow Jones**
- Understand **sector rotation**, **monthly trends**, and **policy event impacts**

---

## 🔍 Key Business Questions

- Which sector contributed most to the ETF's performance?
- How did the ETF fare against major indices over the year?
- Which tickers showed the highest **risk-adjusted** return?
- What was the **volatility** of each constituent and sector?
- How did the market respond to the **Fed rate Decision** in March 2025 and April 2025?

---

## 📈 Analytical Summary

| Metric                      | Highlight                             |
|----------------------------|----------------------------------------|
| **Top Sector (Return)**    | Communication Services: +38.4%        |
| **Worst Sector (Return)**  | Energy: −9.7%                          |
| **Best Performing Stock**  | RCL: +99.9%                            |
| **Top Index Performance**  | NASDAQ Composite: +13.4%              |
| **ETF vs S&P 500**         | ETF average return beat index by 11%  |
| **Fed Rate Impact**        | All sectors showed a negative drift   |

---

## 🧮 Analytical Logic

### 💹 Custom ETF Construction
- Each sector contributed 10 tickers, equally weighted
- Final performance per ticker computed as:  
- Sector and ETF return calculated as average of constituent returns

### 📊 Volatility Assessment
- Used `STDDEV(adj_close)` to measure daily fluctuations by ticker

### 📆 Monthly Sector Trends
- Grouped average prices per sector per month to detect patterns

### 💸 $10,000 Investment Simulation
- For each sector: tracked normalized investment value growth over time

### 📉 Event Reaction
- Compared sector prices **pre vs post** Fed rate decision (March → April 2025)
- Tagged each sector as `Positive` or `Negative` trend

---

## 📊 Interactive Dashboard

Here’s an **interactive Tableau dashboard** where you can explore the results yourself:

[![ETF Dashboard Preview](https://github.com/ghazalayobi/data-projects/blob/main/stock_prices/plots/dashboard_preview.png)](https://public.tableau.com/views/CustomETFvsSP500NASDAQDowOne-YearSectorAnalysis/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

👉 **Click the image above** to view the live dashboard on Tableau Public.

---

## 🧰 Tools Used

- **Primary Logic**: SQL (PostgreSQL)
- **ETL & API**: Python (`yfinance`, `pandas`)
- **Charts & Visuals**: `matplotlib`, `seaborn`
- **Dashboard**: Tableau

---

## 🚀 What You’ll Learn

- How to build a **sector-balanced portfolio** using real-world data
- How to measure **ETF-like performance** using custom logic
- How **sector rotation** and **macroeconomic shifts** influence stock prices
- How structured queries can power deep financial analytics
