
/*
 
===============================================
Exploratory Data Analysis
===============================================

Project Goal:
-----------------------------------------------
To analyze and compare the performance, volatility, and trends of 70+ US stocks across sectors
over a 1 year period using SQL. This project includes sector benchmarking, volatility assessment,
monthly trend detection, and return analysis for both stocks and indices.

Data Source:
- Extracted using yfinance Python API
- Date Range: 2024-07-01 to 2025-06-30
- Includes tickers from 7 S&P sectors + 3 major indices (S&P500, NASDAQ, Dow Jones)


Script Goal:
-----------------------------------------------
This script performs an initial exploratory data analysis (EDA) on the `stock_prices` dataset 
and its associated `ticker_metadata`. The goal is to understand the data’s time range, 
stock coverage, price distribution, missing values, sector representation, and performance 
trends. This forms the foundation for deeper analytics and modeling tasks.
 */

/*  1. Null or Zero Prices Check */
SELECT * FROM stock_prices WHERE adj_close IS NULL OR adj_close <= 0;
-- zero found

/*  2. Unexpected Tickers */
SELECT DISTINCT ticker 
FROM stock_prices 
WHERE ticker NOT IN (SELECT ticker FROM ticker_metadata);
-- zero found

/*  3. Tickers with Missing Sector Info */
SELECT * FROM ticker_metadata WHERE sector IS NULL;
-- zero found

/*  4. Time Range and Duration */
SELECT
  MIN(date) AS start_date,
  MAX(date) AS end_date,
  EXTRACT(MONTH FROM AGE(MAX(date), MIN(date))) AS duration_in_months,
  COUNT(DISTINCT date) AS total_days
FROM stock_prices;

/*
 Result
 
start_date|end_date  |duration_in_months|total_days|
----------+----------+------------------+----------+
2024-07-01|2025-06-27|                11|       249|
*/


/*  5. Count of Unique Tickers */
SELECT COUNT(DISTINCT ticker) AS unique_tickers FROM stock_prices;

/*
unique_tickers|
--------------+
            73|
 */

/*  6. Records per Ticker */
SELECT ticker, COUNT(*) AS num_days 
FROM stock_prices 
GROUP BY ticker
ORDER BY num_days DESC;
/*

ticker|num_days|
------+--------+
MCD   |     249|
TGT   |     249|
DIS   |     249|...

I have selected same date range for all tickers
*/

/*  7. Average Adjusted Close Price */
SELECT ticker, ROUND(AVG(adj_close)::NUMERIC, 2) AS avg_price
FROM stock_prices
GROUP BY ticker
ORDER BY avg_price DESC;

/*
 ticker|avg_price|
------+---------+
^DJI  | 42124.24|
^IXIC | 18449.52|
^GSPC |  5765.88|
BKNG  |  4606.10|
BLK   |   939.57|
NFLX  |   888.76|
LLY   |   831.59|
INTU  |   636.61|
META  |   588.37|
GS    |   549.66|
TMO   |   525.31|
UNH   |   501.99|
LMT   |   496.02|
ADBE  |   465.96|
DE    |   434.18|
MSFT  |   422.07|
HD    |   376.18|
CHTR  |   359.23|
CAT   |   353.11|
AMGN  |   295.75|
TSLA  |   295.36|
MCD   |   291.51|
CRM   |   287.23|
AXP   |   275.96|
LOW   |   242.77|
JPM   |   234.64|
TMUS  |   225.23|
AAPL  |   222.73|
RCL   |   212.14|
HON   |   211.78|
AMZN  |   200.16|
AVGO  |   191.53|
GE    |   189.98|
TXN   |   188.73|
BA    |   172.31|
GOOGL |   171.37|
ORCL  |   160.68|
JNJ   |   153.45|
MPC   |   153.15|
CVX   |   146.39|
MMM   |   134.21|
VLO   |   132.00|
AMD   |   129.37|
TGT   |   126.09|
EOG   |   122.39|
RTX   |   122.25|
PSX   |   122.10|
ABT   |   119.93|
MS    |   117.03|
UPS   |   116.73|
XOM   |   110.56|
DIS   |   101.28|
COP   |    99.92|
MU    |    98.73|
MRK   |    96.84|
SBUX  |    91.87|
SCHW  |    75.05|
NKE   |    71.81|
C     |    68.27|
WFC   |    67.13|
CVS   |    58.77|
BMY   |    50.95|
OXY   |    49.05|
BAC   |    42.07|
TFC   |    41.61|
VZ    |    41.11|
SLB   |    39.94|
BKR   |    38.97|
CSX   |    32.27|
PFE   |    25.61|
T     |    23.30|
PARA  |    11.00|
WBD   |     9.19|
 */

/*  8. Ticker Count by Sector and Type */
SELECT sector, type, COUNT(*) AS num_tickers
FROM ticker_metadata
GROUP BY sector, type
ORDER BY sector;

/*
 sector                |type |num_tickers|
----------------------+-----+-----------+
Communication_Services|Stock|         10|
Consumer_Discretionary|Stock|         10|
Dow_Jones             |Index|          1|
Energy                |Stock|         10|
Financials            |Stock|         10|
Healthcare            |Stock|         10|
Industrials           |Stock|         10|
NASDAQ_Composite      |Index|          1|
S&P_500               |Index|          1|
Technology            |Stock|         10|
 */

/*  9. Percent Change from Min to Max */
SELECT 
  ticker, 
  ROUND(((MAX(adj_close) - MIN(adj_close)) / MIN(adj_close) * 100)::NUMERIC, 2) AS prc_return
FROM stock_prices
GROUP BY ticker
ORDER BY prc_return DESC;

/*

ticker|prc_return|
------+----------+
TSLA  |    150.24|
AMD   |    135.21|
UNH   |    126.07|
RCL   |    125.36|
NFLX  |    121.05|
MU    |    110.43|
AVGO  |    100.52|
WBD   |     86.14|
TGT   |     78.22|
ORCL  |     75.27|
OXY   |     74.06|
BKNG  |     73.56|
ADBE  |     72.51|
MRK   |     71.51|
NKE   |     66.21|
GE    |     63.99|
BMY   |     63.51|
META  |     62.76|
SBUX  |     62.55|
CVS   |     62.34|
T     |     61.78|
TMO   |     59.43|
BA    |     59.24|
WFC   |     58.79|
MMM   |     58.05|
TMUS  |     57.37|
MS    |     56.28|
DE    |     55.80|
CRM   |     55.28|
PSX   |     54.39|
UPS   |     54.19|
C     |     53.99|
GS    |     53.65|
VLO   |     52.71|
SLB   |     52.42|
RTX   |     52.28|
CAT   |     51.62|
JPM   |     50.75|
DIS   |     50.34|
AMZN  |     50.33|
TXN   |     50.18|
AAPL  |     50.06|
MPC   |     50.00|
BKR   |     49.17|
SCHW  |     47.20|
CHTR  |     47.04|
AXP   |     44.96|
LMT   |     44.33|
INTU  |     42.98|
GOOGL |     42.46|
ABT   |     41.52|
PFE   |     40.84|
MSFT  |     40.56|
BLK   |     38.98|
BAC   |     38.82|
COP   |     37.97|
CSX   |     37.17|
TFC   |     36.85|
LOW   |     33.81|
LLY   |     33.78|
MCD   |     33.02|
^IXIC |     32.78|
EOG   |     31.03|
HD    |     30.76|
AMGN  |     29.43|
HON   |     28.37|
PARA  |     27.79|
CVX   |     26.01|
^GSPC |     23.89|
VZ    |     23.56|
XOM   |     23.33|
^DJI  |     19.57|
JNJ   |     18.99|
 */

/*
===============================================
 Summary of EDA
-----------------------------------------------
- Time Range: 2024-07-01 to 2025-06-27 (249 trading days)
- Unique Tickers: 73 (all with full records)
- No missing or invalid adjusted close values
- Sector Coverage: 10 stock sectors + 3 indices
- Price Trends: E.g., TSLA +150%, AVGO +100%, MCD avg $291
===============================================
*/


