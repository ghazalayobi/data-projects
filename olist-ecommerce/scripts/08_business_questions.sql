

/*===============================================================================
Olist E-Commerce Project – Analytical Queries
===============================================================================
Script Purpose:
This script contains analytical SQL queries designed to explore the Olist e-commerce dataset.
It analyzes customer behavior, sales performance, delivery efficiency, seller performance,
and payment trends. Queries use the Gold layer for aggregated/cleaned data. 
===============================================================================*/


/*===============================================================================
A. Payment & Transaction Analysis
===============================================================================*/

-- Q1. How do payment methods affect order value and purchase frequency?

SELECT
    fp.payment_type,
    COUNT(DISTINCT fp.order_id) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS order_pct,
    ROUND(AVG(foi.price + foi.freight_value), 2) AS avg_payment
FROM gold.fact_payments fp
JOIN gold.fact_order_items foi ON fp.order_id = foi.order_id
GROUP BY fp.payment_type
ORDER BY avg_payment DESC;



-- Q2. What is the average time between order placement and payment confirmation, 
--     and does it differ by payment type?
SELECT 
    fp.payment_type,
    ROUND(AVG(EXTRACT(EPOCH FROM (fo.approved_at - fo.purchase_timestamp)) / 3600), 2) AS avg_time_hours
FROM gold.fact_orders fo
JOIN gold.fact_payments fp ON fo.order_id = fp.order_id
WHERE fo.approved_at IS NOT NULL 
  AND fo.purchase_timestamp IS NOT NULL
GROUP BY fp.payment_type
ORDER BY avg_time_hours DESC;


/*===============================================================================
B. Customer Behavior & Retention
===============================================================================*/

-- Q3. What is the trend of customer acquisition month over month?

WITH first_orders AS (
    SELECT 
        customer_id, 
        MIN(purchase_timestamp) AS first_order_date
    FROM gold.fact_orders
    GROUP BY customer_id
)
SELECT 
    DATE_TRUNC('month', first_order_date) AS acquisition_month,
    COUNT(customer_id) AS new_customers
FROM first_orders
GROUP BY acquisition_month
ORDER BY acquisition_month;



-- Q4. What’s the average time between first and second purchases?

WITH customer_orders AS (
    SELECT 
        dc.unique_id,
        fo.order_id,
        fo.purchase_timestamp,
        ROW_NUMBER() OVER (PARTITION BY dc.unique_id ORDER BY fo.purchase_timestamp) AS order_rank
    FROM gold.fact_orders fo
    JOIN gold.dim_customers dc
      ON fo.customer_id = dc.customer_id
), 
first_second_orders AS (
    SELECT 
        unique_id,
        MAX(CASE WHEN order_rank = 1 THEN purchase_timestamp END) AS first_order_date,
        MAX(CASE WHEN order_rank = 2 THEN purchase_timestamp END) AS second_order_date
    FROM customer_orders
    WHERE order_rank <= 2
    GROUP BY unique_id
)
SELECT
    unique_id,
    first_order_date,
    second_order_date,
    ROUND(EXTRACT(EPOCH FROM (second_order_date - first_order_date)) / 86400.0, 2) AS days_between
FROM first_second_orders
WHERE second_order_date IS NOT NULL
ORDER BY days_between desc
LIMIT 10;


-- Q5. What is the lifetime value (LTV) of a customer over different periods (monthly)? 

SELECT 
    fo.customer_id,
    DATE_TRUNC('month', fo.purchase_timestamp) AS month,
    SUM(foi.price + foi.freight_value) AS revenue
FROM gold.fact_orders fo
JOIN gold.fact_order_items foi ON fo.order_id = foi.order_id
GROUP BY fo.customer_id, month
ORDER BY revenue DESC
LIMIT 10;



-- Q6. How do customer purchase behaviors differ between states and cities?

SELECT 
    dc.state,
    dc.city,
    COUNT(DISTINCT fo.order_id) AS num_orders,
    ROUND(AVG(foi.price), 2) AS avg_order_value
FROM gold.fact_orders fo
JOIN gold.dim_customers dc ON fo.customer_id = dc.customer_id
JOIN gold.fact_order_items foi ON fo.order_id = foi.order_id
GROUP BY dc.state, dc.city
ORDER BY num_orders DESC
LIMIT 10;




/*===============================================================================
C. Cart Size & Order Composition
===============================================================================*/

-- Q7. What is the average cart value per order? 

SELECT
    ROUND(AVG(order_total), 2) AS avg_value
FROM (
    SELECT 
        foi.order_id,
        SUM(foi.price + foi.freight_value) AS order_total
    FROM gold.fact_order_items foi
    GROUP BY foi.order_id
) AS order_totals;



-- Q8. What is the average number of items per order? 

SELECT 
    ROUND(AVG(item_count), 2) AS avg_items_per_order
FROM (
    SELECT 
        order_id,
        COUNT(*) AS item_count
    FROM gold.fact_order_items
    GROUP BY order_id
) AS order_item_counts;



-- Q9. How does cart size vary by customer segment? 

SELECT 
    fo.customer_state AS customer_segment,
    ROUND(AVG(order_totals.item_count), 2) AS avg_items_per_order,
    ROUND(AVG(order_totals.order_total), 2) AS avg_cart_value
FROM (
    SELECT 
        foi.order_id,
        COUNT(*) AS item_count,
        SUM(foi.price + foi.freight_value) AS order_total
    FROM gold.fact_order_items foi
    GROUP BY foi.order_id
) AS order_totals
JOIN gold.fact_orders fo 
    ON fo.order_id = order_totals.order_id
GROUP BY fo.customer_state
ORDER BY avg_cart_value DESC
LIMIT 10;



/*===============================================================================
D. Seller Performance
===============================================================================*/

-- Q10. Which top 10 sellers generate the highest total revenue, and what is their average review score? 


SELECT 
    s.seller_id,
    SUM(foi.price) AS total_sales,
    ROUND(AVG(fr.score), 2) AS avg_score
FROM gold.dim_sellers s
JOIN gold.fact_order_items foi ON s.seller_id = foi.seller_id
JOIN gold.fact_orders fo ON foi.order_id = fo.order_id
JOIN gold.fact_reviews fr ON fo.order_id = fr.order_id
GROUP BY s.seller_id
ORDER BY total_sales DESC
LIMIT 10;



-- Q11. How does the seller’s location (state/region) affect the average delivery delay? 

WITH order_delays AS (
    SELECT 
        o.order_id,
        DATE_PART('day', o.delivered_customer_date - o.estimated_delivery_date) AS delay_days
    FROM gold.fact_orders o
    WHERE o.delivered_customer_date > o.estimated_delivery_date
),
item_delay AS (
    SELECT
        oi.seller_id,
        s.state AS seller_state,
        od.delay_days,
        oi.order_id
    FROM gold.fact_order_items oi
    JOIN order_delays od 
        ON oi.order_id = od.order_id
    LEFT JOIN gold.dim_sellers s 
        ON oi.seller_id = s.seller_id
)
SELECT
    seller_state,
    COUNT(DISTINCT order_id) AS distinct_orders_covered,
    COUNT(*) AS item_rows_count,
    ROUND(AVG(delay_days)::NUMERIC, 2) AS avg_delay_days,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY delay_days)::NUMERIC, 2) AS median_delay_days,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY delay_days)::NUMERIC, 2) AS late_delay_days,
    ROUND(STDDEV_POP(delay_days)::NUMERIC, 2) AS stddev_delay_days
FROM item_delay
GROUP BY seller_state
ORDER BY avg_delay_days DESC NULLS LAST;


-- Q12. How does the seller’s location affect the average freight cost per order? 

WITH per_seller_order AS (
    SELECT
        oi.seller_id,
        s.state AS seller_state,
        oi.order_id,
        SUM(oi.freight_value) AS seller_order_freight,
        SUM(oi.price) AS seller_order_item_price,
        SUM(oi.price + oi.freight_value) AS seller_order_total
    FROM gold.fact_order_items oi
    LEFT JOIN gold.dim_sellers s 
        ON oi.seller_id = s.seller_id
    GROUP BY oi.seller_id, s.state, oi.order_id
)
SELECT
    seller_state,
    COUNT(DISTINCT order_id) AS num_orders,
    ROUND(AVG(seller_order_freight)::NUMERIC, 2) AS avg_freight_per_order,
    ROUND(AVG(seller_order_total)::NUMERIC, 2) AS avg_total_per_order,
    ROUND(AVG(
        CASE 
            WHEN seller_order_total > 0 THEN seller_order_freight / seller_order_total 
            ELSE 0 
        END
    )::NUMERIC, 4) AS avg_freight_share
FROM per_seller_order
GROUP BY seller_state
ORDER BY avg_freight_per_order DESC NULLS LAST;



/*===============================================================================
E. Delivery & Review Impact
===============================================================================*/

-- Q13. Avg delivery delay per seller vs review scores
SELECT 
    s.seller_id,
    ROUND(AVG(DATE_PART('day', o.delivered_customer_date - o.estimated_delivery_date))::NUMERIC, 2) AS avg_delay_days,
    ROUND(AVG(r.score), 2) AS avg_review_score
FROM gold.fact_orders o
JOIN gold.fact_order_items oi 
    ON o.order_id = oi.order_id
JOIN gold.dim_sellers s 
    ON oi.seller_id = s.seller_id
JOIN gold.fact_reviews r 
    ON o.order_id = r.order_id
WHERE o.delivered_customer_date >= o.estimated_delivery_date
GROUP BY s.seller_id
ORDER BY avg_delay_days DESC
LIMIT 10;



-- Q14. Top product categories by revenue by region. 

SELECT 
    f.category_name,
    c.state,
    ROUND(SUM(f.total_revenue), 2) AS total_revenue
FROM gold.fact_order_items f
JOIN gold.dim_customers c 
    ON f.customer_id = c.customer_id
GROUP BY f.category_name, c.state
ORDER BY total_revenue DESC
LIMIT 10;



/*===============================================================================
F. Order Date Analyses
===============================================================================*/

-- Q15. What is the month-over-month growth in total revenue over the years?

WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', o.purchase_timestamp) AS order_month,
        SUM(oi.price + oi.freight_value) AS total_revenue
    FROM gold.fact_orders o
    JOIN gold.fact_order_items oi 
        ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY 1
)
SELECT 
    order_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
    ROUND(
        (
            (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month)) / 
            NULLIF(LAG(total_revenue) OVER (ORDER BY order_month), 0)
        ) * 100,
        2
    ) AS mom_growth_percentage
FROM monthly_revenue
ORDER BY order_month;



-- Q16. Which days of the week see the highest average order value and order count?

SELECT 
    EXTRACT(DOW FROM order_date) AS weekday_num,
    TO_CHAR(order_date, 'FMDay') AS order_weekday,
    SUM(total_revenue) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(total_revenue) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS avg_order_value
FROM gold.fact_order_items
GROUP BY weekday_num, order_weekday
ORDER BY weekday_num;



/*===============================================================================
F. Delivery Date Analyses
===============================================================================*/

-- Q17. What percentage of orders were delivered on or before the estimated date each month?

WITH deliveries AS (
    SELECT 
        DATE_TRUNC('month', purchase_timestamp) AS order_month,
        CASE WHEN delivered_customer_date <= estimated_delivery_date THEN 1 ELSE 0 END AS on_time_flag
    FROM gold.fact_orders
    WHERE delivered_customer_date IS NOT NULL
      AND estimated_delivery_date IS NOT NULL
)
SELECT 
    order_month,
    COUNT(*) AS total_orders,
    SUM(on_time_flag) AS on_time_deliveries,
    ROUND((SUM(on_time_flag)::NUMERIC / COUNT(*)) * 100, 2) AS on_time_percentage
FROM deliveries
GROUP BY order_month
ORDER BY order_month;

-- Q18. Are deliveries on certain weekdays faster or slower on average?

SELECT
    TO_CHAR(delivered_customer_date, 'FMDay') AS delivery_weekday,
    ROUND(AVG(EXTRACT(EPOCH FROM (delivered_customer_date - purchase_timestamp)) / 86400), 2) AS avg_delivery_days,
    COUNT(order_id) AS total_deliveries
FROM gold.fact_orders
WHERE delivered_customer_date IS NOT NULL 
  AND purchase_timestamp IS NOT NULL
GROUP BY delivery_weekday
ORDER BY avg_delivery_days ASC;



/*===============================================================================
G. Payment & Installment Patterns Over Time
===============================================================================*/

-- Q19. How has the average number of payment installments changed over time?
SELECT 
    DATE_TRUNC('month', o.purchase_timestamp) AS order_month,
    ROUND(AVG(fp.installments)::NUMERIC, 2) AS avg_installments
FROM gold.fact_payments fp
JOIN gold.fact_orders o 
    ON fp.order_id = o.order_id
WHERE fp.installments IS NOT NULL
GROUP BY order_month
ORDER BY order_month;



-- Q20. Do longer installments correlate with longer delivery times?
WITH delivery_duration AS (
    SELECT
        order_id,
        EXTRACT(EPOCH FROM (delivered_customer_date - purchase_timestamp)) / 86400 AS delivery_days
    FROM gold.fact_orders
    WHERE delivered_customer_date IS NOT NULL
      AND purchase_timestamp IS NOT NULL
)
SELECT
    fp.installments,
    COUNT(dd.order_id) AS order_count,
    ROUND(AVG(dd.delivery_days), 2) AS avg_delivery_days
FROM gold.fact_payments fp
JOIN delivery_duration dd 
    ON fp.order_id = dd.order_id
WHERE fp.installments IS NOT NULL 
GROUP BY fp.installments
ORDER BY fp.installments;









