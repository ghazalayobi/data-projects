
/*
===============================================
Advanced Analytics and Business Questions
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

------------------------------------------------
Script Goal
------------------------------------------------
To uncover deeper trends, sector performance, and investment insights 
from historical stock price data using advanced SQL queries.
 */

/*  1. Price Volatility by Ticker */
-- Top 10 most volatile tickers
SELECT ticker, ROUND(STDDEV(adj_close)::NUMERIC, 2) AS volatility
FROM stock_prices
GROUP BY ticker
ORDER BY volatility DESC
LIMIT 10;

/*
 ticker|volatility|
------+----------+
^DJI  |   1616.99|
^IXIC |   1074.93|
BKNG  |    583.63|
^GSPC |    245.56|
NFLX  |    187.18|
UNH   |     91.35|
BLK   |     71.69|
TMO   |     69.81|
TSLA  |     69.65|
ADBE  |     67.16|
META  |     66.70|
 */


/* ️ 2. Monthly Average Prices by Sector */
-- Trends per sector per month, it detects seasonal patterns in different sectors.
SELECT 
  TO_CHAR(date, 'YYYY-MM') AS month,
  tm.sector,
  ROUND(AVG(sp.adj_close)::NUMERIC, 2) AS avg_monthly_price
FROM stock_prices sp
JOIN ticker_metadata tm ON sp.ticker = tm.ticker
GROUP BY tm.sector, month
ORDER BY month, tm.sector;

/*
 example.
2025-06|Communication_Services|           294.52|
2025-06|Consumer_Discretionary|           740.54|
2025-06|Dow_Jones             |         42682.32|
2025-06|Energy                |            99.56|
2025-06|Financials            |           265.40|
2025-06|Healthcare            |           228.29|
2025-06|Industrials           |           244.49|
2025-06|NASDAQ_Composite      |         19636.65|
2025-06|S&P_500               |          6020.74|
2025-06|Technology            |           299.52|
 */


/*  3. Return from First to Last Day per Ticker */
-- Total performance for each ticker over the full year

WITH first_last AS (
  SELECT 
    ticker,
    FIRST_VALUE(adj_close) OVER (PARTITION BY ticker ORDER BY date ASC 
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS first_price,
    LAST_VALUE(adj_close) OVER (PARTITION BY ticker ORDER BY date 
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_price
  FROM stock_prices
)
  SELECT DISTINCT 
    ticker,
    ROUND(((last_price - first_price) / first_price * 100)::numeric, 2) as return_pct
  FROM first_last
order by return_pct;

/*
 ticker|pct_return|
------+----------+
UNH   |    -36.33|
MRK   |    -36.07|
ADBE  |    -31.10|
OXY   |    -30.92|
TGT   |    -29.50|
SLB   |    -24.90|
TMO   |    -24.39|
UPS   |    -21.33|
COP   |    -18.69|
LLY   |    -14.61|
PSX   |    -12.31|
VLO   |    -12.08|
AMD   |     -8.80|
PFE   |     -8.55|
AMGN  |     -8.02|
AAPL  |     -6.80|
MU    |     -4.70|
NKE   |     -4.22|
CVX   |     -3.96|
MPC   |     -2.10|
GOOGL |     -1.96|
EOG   |     -1.60|
XOM   |     -1.54|
CSX   |     -0.54|
LMT   |      0.91|
LOW   |      6.69|
JNJ   |      7.47|
CRM   |      7.51|
VZ    |      8.20|
MSFT  |      9.42|
TXN   |      9.53|
HON   |     10.77|
BKR   |     11.44|
^DJI  |     11.87|
HD    |     12.33|
^GSPC |     12.75|
AMZN  |     13.24|
^IXIC |     13.39|
TFC   |     13.93|
BA    |     14.92|
BMY   |     17.74|
CAT   |     18.80|
MCD   |     19.36|
INTU  |     20.11|
BAC   |     20.66|
SBUX  |     22.40|
CVS   |     23.23|
SCHW  |     24.27|
PARA  |     25.78|
DIS   |     26.45|
ABT   |     32.82|
TMUS  |     33.20|
WFC   |     34.36|
CHTR  |     35.45|
BLK   |     36.87|
AXP   |     37.20|
C     |     37.53|
JPM   |     42.99|
DE    |     43.75|
META  |     45.86|
MS    |     46.42|
BKNG  |     47.69|
RTX   |     48.37|
ORCL  |     48.57|
GS    |     52.12|
TSLA  |     54.21|
MMM   |     54.23|
T     |     55.66|
WBD   |     59.15|
GE    |     61.17|
AVGO  |     66.03|
NFLX  |     96.42|
RCL   |     99.99|
 */

/*  4. Sector-Level Average Return */
-- Total performance for each ticker over the full year
WITH first_last AS (
  SELECT 
    tm.sector,
    sp.ticker,
    FIRST_VALUE(adj_close) OVER (PARTITION BY sp.ticker ORDER BY sp.date) AS first_price,
    LAST_VALUE(adj_close) OVER (PARTITION BY sp.ticker ORDER BY sp.date 
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_price
  FROM stock_prices sp
  JOIN ticker_metadata tm ON sp.ticker = tm.ticker
),
returns AS (
  SELECT 
    sector,
    ROUND((AVG(((last_price - first_price) / first_price) * 100))::numeric, 2) AS percent_change,
    ROUND((AVG(((last_price / first_price) * 10000)))::numeric, 2) AS final_value,
    CASE 
      WHEN AVG(last_price) > AVG(first_price) THEN 'Gain'
      ELSE 'Loss'
    END AS investment_trend
  FROM first_last
  GROUP BY sector
)
SELECT * 
FROM returns
ORDER BY final_value DESC;

/*
sector                |percent_change|final_value|investment_trend|
----------------------+--------------+-----------+----------------+
Communication_Services|         38.42|   13842.18|Gain            |
Financials            |         34.63|   13463.31|Gain            |
Consumer_Discretionary|         24.22|   12421.77|Gain            |
Industrials           |         23.10|   12310.34|Gain            |
NASDAQ_Composite      |         13.39|   11339.07|Gain            |
S&P_500               |         12.75|   11274.83|Gain            |
Dow_Jones             |         11.87|   11187.08|Gain            |
Technology            |         10.98|   11097.64|Gain            |
Healthcare            |         -4.67|    9532.98|Loss            |
Energy                |         -9.67|    9033.48|Loss            |

 */

/*  5. Top/Bottom Performers in Last 6 Months */
-- Top 5

WITH first_last AS (
  SELECT 
    ticker,
    FIRST_VALUE(adj_close) OVER (PARTITION BY ticker ORDER BY date ASC 
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS first_price,
    LAST_VALUE(adj_close) OVER (PARTITION BY ticker ORDER BY date 
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_price
  FROM stock_prices
  WHERE date BETWEEN '2025-01-01' AND '2025-06-30')
SELECT distinct ticker,
       ROUND(((last_price - first_price) / first_price)::numeric * 100, 2) AS return_pct
FROM first_last
ORDER BY return_pct
LIMIT 5;

/*
 * Top 5
ticker|return_pct|
------+----------+
CVS   |     58.47|
GE    |     51.24|
NFLX  |     49.21|
MU    |     43.05|
RCL   |     36.00|
 */

/*
 * Bottom 5
ticker|return_pct|
------+----------+
UNH   |    -38.03|
TGT   |    -26.22|
TMO   |    -21.72|
MRK   |    -18.74|
AAPL  |    -17.34|

 */

/*  6. Compare pre/post Fed rate Decision (March 2025 vs April 2025) */
SELECT
  sp.ticker,
  ROUND((AVG(sp.adj_close) FILTER (WHERE sp.date BETWEEN '2025-03-01' AND '2025-03-31'))::numeric, 2) AS avg_march,
  ROUND((AVG(sp.adj_close) FILTER (WHERE sp.date BETWEEN '2025-04-01' AND '2025-04-30'))::numeric, 2) AS avg_april,
  ROUND((
    AVG(sp.adj_close) FILTER (WHERE sp.date BETWEEN '2025-04-01' AND '2025-04-30') -
    AVG(sp.adj_close) FILTER (WHERE sp.date BETWEEN '2025-03-01' AND '2025-03-31'))::numeric, 
  2) AS diff,
  CASE 
    WHEN AVG(sp.adj_close) FILTER (WHERE sp.date BETWEEN '2025-04-01' AND '2025-04-30') >
         AVG(sp.adj_close) FILTER (WHERE sp.date BETWEEN '2025-03-01' AND '2025-03-31')
    THEN 'Positive Trend'
    ELSE 'Negative Trend'
  END AS price_trend
FROM stock_prices sp
GROUP BY sp.ticker
ORDER BY diff DESC;

/*
 ticker|avg_march|avg_april|diff    |price_trend   |
------+---------+---------+--------+--------------+
NFLX  |   940.85|   983.15|   42.30|Positive Trend|
LMT   |   454.33|   459.12|    4.79|Positive Trend|
UNH   |   493.83|   498.17|    4.34|Positive Trend|
MCD   |   305.66|   309.82|    4.16|Positive Trend|
TSLA  |   255.81|   257.15|    1.34|Positive Trend|
CVS   |    65.74|    66.46|    0.73|Positive Trend|
T     |    26.68|    27.08|    0.40|Positive Trend|
VZ    |    43.38|    43.22|   -0.17|Negative Trend|
PARA  |    11.63|    11.14|   -0.49|Negative Trend|
SCHW  |    76.72|    76.12|   -0.60|Negative Trend|
ABT   |   130.51|   128.40|   -2.11|Negative Trend|
CSX   |    30.02|    27.82|   -2.20|Negative Trend|
WBD   |    10.73|     8.52|   -2.21|Negative Trend|
PFE   |    25.42|    22.41|   -3.01|Negative Trend|
BAC   |    41.53|    37.72|   -3.80|Negative Trend|
TFC   |    40.98|    36.55|   -4.42|Negative Trend|
BA    |   166.61|   162.13|   -4.48|Negative Trend|
BKR   |    43.02|    37.64|   -5.38|Negative Trend|
WFC   |    71.37|    65.91|   -5.46|Negative Trend|
XOM   |   111.71|   105.95|   -5.75|Negative Trend|
SLB   |    40.60|    34.80|   -5.80|Negative Trend|
RTX   |   130.85|   124.85|   -6.00|Negative Trend|
JPM   |   238.95|   232.62|   -6.33|Negative Trend|
C     |    70.52|    64.11|   -6.41|Negative Trend|
TMUS  |   260.73|   254.02|   -6.71|Negative Trend|
OXY   |    47.12|    40.06|   -7.07|Negative Trend|
COP   |    97.09|    89.46|   -7.62|Negative Trend|
BMY   |    58.81|    51.01|   -7.81|Negative Trend|
INTU  |   601.52|   593.63|   -7.89|Negative Trend|
MS    |   117.97|   109.41|   -8.56|Negative Trend|
HD    |   361.63|   352.55|   -9.07|Negative Trend|
MSFT  |   386.94|   377.54|   -9.40|Negative Trend|
JNJ   |   162.79|   152.98|   -9.81|Negative Trend|
GOOGL |   165.11|   154.37|  -10.74|Negative Trend|
LOW   |   231.29|   220.46|  -10.83|Negative Trend|
MRK   |    91.39|    80.32|  -11.07|Negative Trend|
HON   |   209.57|   198.50|  -11.07|Negative Trend|
AMD   |   103.45|    92.13|  -11.32|Negative Trend|
EOG   |   123.56|   111.88|  -11.69|Negative Trend|
AVGO  |   186.10|   174.00|  -12.10|Negative Trend|
GE    |   200.56|   187.68|  -12.87|Negative Trend|
MPC   |   142.68|   129.76|  -12.92|Negative Trend|
TGT   |   107.56|    94.10|  -13.45|Negative Trend|
DIS   |   101.21|    87.33|  -13.88|Negative Trend|
MMM   |   148.82|   134.90|  -13.91|Negative Trend|
BKNG  |  4617.56|  4603.05|  -14.51|Negative Trend|
NKE   |    71.45|    56.62|  -14.82|Negative Trend|
AXP   |   269.39|   254.30|  -15.09|Negative Trend|
SBUX  |   100.33|    84.15|  -16.18|Negative Trend|
VLO   |   128.48|   112.30|  -16.18|Negative Trend|
ORCL  |   150.50|   133.95|  -16.55|Negative Trend|
CHTR  |   366.23|   349.46|  -16.77|Negative Trend|
RCL   |   215.40|   198.39|  -17.01|Negative Trend|
AMZN  |   198.51|   181.21|  -17.30|Negative Trend|
UPS   |   114.09|    96.51|  -17.58|Negative Trend|
CVX   |   157.71|   139.83|  -17.88|Negative Trend|
MU    |    94.17|    73.69|  -20.49|Negative Trend|
AAPL  |   222.41|   200.92|  -21.49|Negative Trend|
DE    |   473.29|   451.58|  -21.71|Negative Trend|
PSX   |   123.96|   101.70|  -22.26|Negative Trend|
CRM   |   279.93|   255.30|  -24.64|Negative Trend|
TXN   |   181.59|   155.66|  -25.92|Negative Trend|
AMGN  |   311.59|   285.46|  -26.13|Negative Trend|
CAT   |   336.42|   298.23|  -38.19|Negative Trend|
GS    |   556.67|   513.00|  -43.68|Negative Trend|
LLY   |   846.94|   797.17|  -49.77|Negative Trend|
ADBE  |   410.90|   357.89|  -53.01|Negative Trend|
BLK   |   941.82|   881.53|  -60.29|Negative Trend|
META  |   608.44|   533.12|  -75.31|Negative Trend|
TMO   |   516.49|   438.97|  -77.52|Negative Trend|
^GSPC |  5683.98|  5369.50| -314.49|Negative Trend|
^IXIC | 17828.03| 16678.46|-1149.57|Negative Trend|
^DJI  | 42092.13| 39876.33|-2215.80|Negative Trend|
 */

/*  7. Compare pre/post Fed rate Decision (March 2024 vs April 2025) secor wise */
SELECT
  tm.sector,
  ROUND((AVG(sp.adj_close) FILTER (WHERE sp.date BETWEEN '2025-03-01' AND '2025-03-31'))::numeric, 2) AS avg_march,
  ROUND((AVG(sp.adj_close) FILTER (WHERE sp.date BETWEEN '2025-04-01' AND '2025-04-30'))::numeric, 2) AS avg_april,
  ROUND((
    AVG(sp.adj_close) FILTER (WHERE sp.date BETWEEN '2025-04-01' AND '2025-04-30') -
    AVG(sp.adj_close) FILTER (WHERE sp.date BETWEEN '2025-03-01' AND '2025-03-31'))::numeric, 
  2) AS diff,
  CASE 
    WHEN AVG(sp.adj_close) FILTER (WHERE sp.date BETWEEN '2025-04-01' AND '2025-04-30') >
         AVG(sp.adj_close) FILTER (WHERE sp.date BETWEEN '2025-03-01' AND '2025-03-31')
    THEN 'Positive Trend'
    ELSE 'Negative Trend'
  END AS price_trend
FROM stock_prices sp
JOIN ticker_metadata tm ON sp.ticker = tm.ticker
GROUP BY tm.sector
ORDER BY diff DESC;

/*
 sector                |avg_march|avg_april|diff    |price_trend   |
----------------------+---------+---------+--------+--------------+
Communication_Services|   253.50|   245.14|   -8.36|Negative Trend|
Consumer_Discretionary|   646.52|   635.75|  -10.77|Negative Trend|
Energy                |   101.59|    90.34|  -11.26|Negative Trend|
Industrials           |   226.46|   214.13|  -12.32|Negative Trend|
Financials            |   242.59|   227.13|  -15.46|Negative Trend|
Healthcare            |   270.35|   252.13|  -18.22|Negative Trend|
Technology            |   261.75|   241.47|  -20.28|Negative Trend|
S&P_500               |  5683.98|  5369.50| -314.49|Negative Trend|
NASDAQ_Composite      | 17828.03| 16678.46|-1149.57|Negative Trend|
Dow_Jones             | 42092.13| 39876.33|-2215.80|Negative Trend|
 */
/*
 
===============================================
 Summary of Advanced Analytics Summary
-----------------------------------------------
 Volatility & Trends
	•	Top volatile tickers: ^DJI, ^IXIC, BKNG, TSLA.
	•	Monthly trends showed Tech and Consumer Discretionary rising early in the year; Energy and Healthcare lagged.

 Performance & Returns
	•	Best one year returns: RCL, NFLX, AVGO (+66 to 99%).
	•	Worst performers: UNH, MRK, ADBE (down ~30%+).
	•	Simulated $10K investment:
	•	Top sectors: Communication Services (+38%), Financials (+35%).
	•	Indices: S&P 500, NASDAQ, and Dow returned ~12 to 13%.
	•	Healthcare and Energy ended below starting capital.

 Fed Rate Decision Impact (March 2025 vs April 2025)
	•	All sectors and indices declined post Fed rate decision.
	•	Few stocks like NFLX, UNH showed resilience.
	•	Sector wide April dips: Tech (-$20), Financials (-$15), S&P500 (-$314), Dow (-$2,200+).
===============================================
 */
