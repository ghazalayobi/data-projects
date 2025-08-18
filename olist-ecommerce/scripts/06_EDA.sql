
/*===============================================================================
 Exploratory Data Analysis (EDA) on Silver Schema
 Purpose:
   - Understand table sizes, data distributions, and missing values
   - Explore customer, seller, order, payment, and review behaviors
   - Identify trends in delivery performance, sales, and customer loyalty
   - Generate insights on geography, seasonality, and product categories
===============================================================================*/


/*===============================================================================
Silver Schema – Essential Indexes
===============================================================================*/

/* Customers */
CREATE INDEX idx_silver_customers_customer_id ON silver.customers (customer_id);

/* Sellers */
CREATE INDEX idx_silver_sellers_seller_id ON silver.sellers (seller_id);

/* Products */
CREATE INDEX idx_silver_products_product_id ON silver.products (product_id);

/* Orders */
CREATE INDEX idx_silver_orders_order_id ON silver.orders (order_id);
CREATE INDEX idx_silver_orders_customer_id ON silver.orders (customer_id);

/* Order Items */
CREATE INDEX idx_silver_order_items_order_id ON silver.order_items (order_id);
CREATE INDEX idx_silver_order_items_product_id ON silver.order_items (product_id);
CREATE INDEX idx_silver_order_items_seller_id ON silver.order_items (seller_id);

/* Order Payments */
CREATE INDEX idx_silver_order_payments_order_id ON silver.order_payments (order_id);

/* Order Reviews */
CREATE INDEX idx_silver_order_reviews_order_id ON silver.order_reviews (order_id);



/*===============================================================================
 Part 1: Schema & Data Overview
===============================================================================*/

-- Table sizes (all tables in the silver schema)
SELECT 
    table_schema,
    table_name,
    pg_size_pretty(pg_total_relation_size(
        quote_ident(table_schema) || '.' || quote_ident(table_name)
    )) AS total_size
FROM information_schema.tables
WHERE table_schema = 'silver'
ORDER BY pg_total_relation_size(
    quote_ident(table_schema) || '.' || quote_ident(table_name)
) DESC;

-- Column details for silver schema
SELECT 
    table_name, 
    column_name, 
    data_type
FROM information_schema.columns
WHERE table_schema = 'silver'
ORDER BY table_name, ordinal_position;

-- Quick sample of orders
SELECT *
FROM silver.orders
LIMIT 10;

-- Duplicate order check
SELECT 
    order_id, 
    COUNT(*) 
FROM silver.orders
GROUP BY order_id 
HAVING COUNT(*) > 1;


/*===============================================================================
 Part 2: Price & Freight Analysis
===============================================================================*/

-- Distribution of product price & freight
SELECT 
    MIN(price) AS min_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price,
    MAX(price) AS max_price,
    MIN(freight_value) AS min_freight,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY freight_value) AS median_freight,
    MAX(freight_value) AS max_freight
FROM silver.order_items;

-- Freight cost distribution
SELECT 
    MIN(freight_value) AS min_freight,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY freight_value) AS median_freight,
    ROUND(AVG(freight_value), 2) AS avg_freight,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY freight_value) AS p90_freight,
    MAX(freight_value) AS max_freight
FROM silver.order_items;

-- Freight band analysis (shipping inefficiencies)
SELECT 
    CASE 
        WHEN freight_value = 0 THEN 'Free Shipping'
        WHEN freight_value < 10 THEN 'Low'
        WHEN freight_value < 50 THEN 'Medium'
        ELSE 'High'
    END AS freight_band,
    COUNT(*) AS order_count
FROM silver.order_items
GROUP BY freight_band
ORDER BY order_count DESC;


/*===============================================================================
 Part 3: Orders & Delivery
===============================================================================*/

-- Date range of orders
SELECT
    MIN(purchase_timestamp) AS first_date,
    MAX(purchase_timestamp) AS last_date
FROM silver.orders;

-- Orders by status
SELECT 
    status, 
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM silver.orders
GROUP BY status
ORDER BY order_count DESC;

-- Delivery time stats
SELECT 
    MIN(delivery_time) AS min_delivery_time,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY delivery_time) AS median_delivery,
    AVG(delivery_time) AS avg_delivery_time,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY delivery_time) AS p90_delivery,
    MAX(delivery_time) AS max_delivery_time
FROM silver.orders
WHERE delivery_time IS NOT NULL;

-- Delivery performance over time
SELECT 
    DATE_TRUNC('month', purchase_timestamp) AS purchase_month,
    ROUND(AVG(EXTRACT(DAY FROM delivery_time)), 2) AS avg_delivery_days
FROM silver.orders
WHERE delivery_time IS NOT NULL
GROUP BY purchase_month
ORDER BY purchase_month;

-- Delivery delays by product category
SELECT 
    pct.category_name_english,
    ROUND(AVG(EXTRACT(DAY FROM (o.delivered_customer_date - estimated_delivery_date))), 2) AS avg_delay_days,
    COUNT(*) AS order_count
FROM silver.orders o 
JOIN silver.order_items oi ON o.order_id = oi.order_id
JOIN silver.products p ON oi.product_id = p.product_id
JOIN silver.product_category_translation pct ON p.category_name = pct.category_name
WHERE delivered_customer_date IS NOT NULL 
  AND estimated_delivery_date IS NOT NULL
GROUP BY pct.category_name_english
ORDER BY avg_delay_days DESC;


/*===============================================================================
 Part 4: Customer Insights
===============================================================================*/

-- Missing values in customers
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN unique_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_unique_id,
    SUM(CASE WHEN zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS missing_zip_prefix
FROM silver.customers;

-- Geographic spread of customers
SELECT 
    state, 
    COUNT(*) AS customer_count
FROM silver.customers
GROUP BY state
ORDER BY customer_count DESC;

-- Repeat vs one-time customers
SELECT 
    COUNT(DISTINCT unique_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN order_count > 1 THEN unique_id END) AS repeat_customers,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN order_count > 1 THEN unique_id END) 
          / COUNT(DISTINCT unique_id), 2) AS repeat_customer_pct
FROM (
    SELECT 
        unique_id, 
        COUNT(*) AS order_count
    FROM silver.orders o
    JOIN silver.customers c USING (customer_id)
    GROUP BY unique_id
) t;


/*===============================================================================
 Part 5: Reviews & Ratings
===============================================================================*/

-- Review score distribution
SELECT 
    score, 
    COUNT(*) AS count,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct
FROM silver.order_reviews
GROUP BY score
ORDER BY score DESC;

-- Review score vs delivery time
SELECT 
    r.score, 
    ROUND(AVG(EXTRACT(DAY FROM delivery_time)), 2) AS avg_delivery_days
FROM silver.orders o
JOIN silver.order_reviews r ON o.order_id = r.order_id
WHERE delivery_time IS NOT NULL
GROUP BY r.score
ORDER BY r.score;

-- Review trends over time
SELECT 
    DATE_TRUNC('month', creation_date) AS review_month,
    ROUND(AVG(score), 2) AS avg_review,
    COUNT(*) AS review_count
FROM silver.order_reviews
GROUP BY review_month
ORDER BY review_month;

-- Review score by delay status
SELECT 
    CASE 
        WHEN delivered_customer_date > estimated_delivery_date THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    ROUND(AVG(score), 2) AS avg_review_score,
    COUNT(*) AS review_count
FROM silver.orders o
JOIN silver.order_reviews r ON o.order_id = r.order_id
WHERE score IS NOT NULL
GROUP BY delivery_status;


/*===============================================================================
 Part 6: Sales & Revenue Insights
===============================================================================*/

-- Orders & sales over time
SELECT
    DATE_TRUNC('month', o.purchase_timestamp) AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_sales
FROM silver.orders o
JOIN silver.order_items oi ON o.order_id = oi.order_id
GROUP BY order_month
ORDER BY total_sales DESC;

-- Top states by sales
SELECT 
    c.state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_sales
FROM silver.customers c
JOIN silver.orders o ON c.customer_id = o.customer_id
JOIN silver.order_items oi ON o.order_id = oi.order_id
GROUP BY c.state
ORDER BY total_sales DESC;

-- Top categories sales trends
WITH top_categories AS (
    SELECT 
        category_name,
        SUM(price) AS total_sales
    FROM silver.order_items oi
    JOIN silver.products p ON oi.product_id = p.product_id
    GROUP BY category_name
    ORDER BY total_sales DESC
    LIMIT 5
)
SELECT 
    p.category_name,
    DATE_TRUNC('month', o.purchase_timestamp) AS month,
    ROUND(SUM(oi.price), 2) AS monthly_sales
FROM silver.order_items oi
JOIN silver.orders o ON oi.order_id = o.order_id
JOIN silver.products p ON oi.product_id = p.product_id
JOIN top_categories t ON p.category_name = t.category_name
GROUP BY p.category_name, DATE_TRUNC('month', o.purchase_timestamp)
ORDER BY p.category_name, month;