
/*
===============================================================================
Gold Schema – Creating Views
===============================================================================
Script Purpose:
	Create Gold Layer views implementing a star schema.
	-- This script builds dimension and fact views from cleaned Silver Layer data.
	-- It supports business intelligence by organizing data for easy analysis and reporting.
	-- Includes customer, and seller dimensions and order, 
	   payment, review, and order items facts.
===============================================================================
*/

-- 1. DIMENSION: dim_customers
CREATE OR replace VIEW gold.dim_customers AS 
SELECT DISTINCT
    customer_id,
    unique_id,
    city,
    state
FROM silver.customers;


-- 2. DIMENSION: dim_sellers
CREATE OR REPLACE VIEW gold.dim_sellers AS
SELECT DISTINCT
    seller_id,
    city,
    state
FROM silver.sellers;


-- 3. FACT: fact_orders
CREATE OR REPLACE VIEW gold.fact_orders AS
SELECT
    o.order_id,
    o.customer_id,
    o.status,
    o.purchase_timestamp,
    o.approved_at,
    o.delivered_carrier_date,
    o.delivered_customer_date,
    o.estimated_delivery_date,
    c.state AS customer_state,
    s.state AS seller_state
FROM silver.orders o
LEFT JOIN silver.customers c ON o.customer_id = c.customer_id
LEFT JOIN (
    SELECT order_id, MIN(seller_id) AS seller_id
    FROM silver.order_items
    GROUP BY order_id
) oi ON o.order_id = oi.order_id
LEFT JOIN silver.sellers s ON oi.seller_id = s.seller_id;


-- 4. FACT: fact_reviews
CREATE OR REPLACE VIEW gold.fact_reviews AS
SELECT
    order_id,
    score,
    comment_title,
    comment_message,
    creation_date,
    answer_timestamp
FROM silver.order_reviews;

-- 5. FACT: fact_payments

CREATE OR REPLACE VIEW gold.fact_payments AS
SELECT
    order_id,
    sequential,
    type AS payment_type,
    installments,
    value
FROM silver.order_payments;



-- 6. FACT: fact_order_items
CREATE OR REPLACE VIEW gold.fact_order_items AS
SELECT 
    oi.order_id,
    oi.item_id,
    oi.product_id,
    p.category_name,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_revenue,
    o.customer_id,
    o.purchase_timestamp::DATE AS order_date
FROM silver.order_items AS oi
JOIN silver.orders AS o 
    ON oi.order_id = o.order_id
JOIN silver.products AS p 
    ON oi.product_id = p.product_id;







