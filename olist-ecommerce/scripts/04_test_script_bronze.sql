
/*
====================================================================================
Script Purpose: Data Quality Validation for Bronze Layer (PostgreSQL – Olist Dataset)
====================================================================================

This script performs comprehensive data quality checks on all core tables 
in the `bronze` schema before promotion to the Silver layer. It includes:

- Null, duplicate, and integrity constraint checks on IDs and relationships.
- Basic profiling of ZIP codes, cities, and states.
- Normalization hints (e.g., trimming, unaccenting city names).
- Temporal and value validations on order dates, deliveries, and payments.
- Identification of referential inconsistencies across datasets.

Optional: `unaccent` extension is noted for use when normalizing city/state names.
*/

--============================
-- CHECK: Geolocation Dataset
--============================
SELECT * FROM bronze.olist_geolocation_dataset;

-- Null check
SELECT * FROM bronze.olist_geolocation_dataset 
WHERE geolocation_lat IS NULL OR geolocation_lng IS NULL;

-- Zip code format check
SELECT * FROM bronze.olist_geolocation_dataset 
WHERE LENGTH(geolocation_zip_code_prefix::text) != 5;

-- City name inspection
SELECT DISTINCT geolocation_city 
FROM bronze.olist_geolocation_dataset 
ORDER BY geolocation_city;

-- State format and null check
SELECT geolocation_state 
FROM bronze.olist_geolocation_dataset 
WHERE geolocation_state != TRIM(geolocation_state) OR geolocation_state IS NULL;

-- City name normalization (remove accents)
SELECT DISTINCT 
  unaccent(LOWER(TRIM(geolocation_city))) AS normalized_city
FROM bronze.olist_geolocation_dataset;

--============================
-- CHECK: Customers Dataset
--============================
SELECT * FROM bronze.olist_customers_dataset;

-- Null & duplicate check
SELECT * FROM bronze.olist_customers_dataset 
WHERE customer_id IS NULL OR customer_unique_id IS NULL;

SELECT customer_id, COUNT(*) 
FROM bronze.olist_customers_dataset 
GROUP BY customer_id HAVING COUNT(*) > 1;

SELECT customer_unique_id, COUNT(*) 
FROM bronze.olist_customers_dataset 
GROUP BY customer_unique_id HAVING COUNT(*) > 1;

-- Zip code length check
SELECT COUNT(*) 
FROM bronze.olist_customers_dataset 
WHERE LENGTH(customer_zip_code_prefix::text) != 5;

-- Zip code validation vs geolocation
SELECT DISTINCT
  LPAD(customer_zip_code_prefix::text, 5, '0') AS missing_zip
FROM bronze.olist_customers_dataset
WHERE LPAD(customer_zip_code_prefix::text, 5, '0') NOT IN (
  SELECT DISTINCT LPAD(geolocation_zip_code_prefix::text, 5, '0')
  FROM bronze.olist_geolocation_dataset
)
ORDER BY missing_zip;

-- City/state normalization
SELECT DISTINCT unaccent(LOWER(TRIM(customer_city))) AS normalized_city
FROM bronze.olist_customers_dataset;

SELECT DISTINCT customer_state FROM bronze.olist_customers_dataset;


--============================
-- CHECK: Sellers Dataset
--============================
SELECT * FROM bronze.olist_sellers_dataset;

-- Null & duplicate check
SELECT * FROM bronze.olist_sellers_dataset WHERE seller_id IS NULL;

SELECT seller_id, COUNT(*) 
FROM bronze.olist_sellers_dataset 
GROUP BY seller_id HAVING COUNT(*) > 1;

-- Zip code check
SELECT COUNT(*) 
FROM bronze.olist_sellers_dataset 
WHERE LENGTH(seller_zip_code_prefix::text) != 5;

-- Validate zip codes with geolocation
SELECT DISTINCT 
  LPAD(seller_zip_code_prefix::text, 5, '0') AS missing_zip
FROM bronze.olist_sellers_dataset
WHERE LPAD(seller_zip_code_prefix::text, 5, '0') NOT IN (
  SELECT DISTINCT LPAD(geolocation_zip_code_prefix::text, 5, '0')
  FROM bronze.olist_geolocation_dataset
);

-- City normalization
SELECT DISTINCT 
  CASE 
    WHEN regexp_replace(seller_city, '[\\/].*$', '') ~ '^[0-9\s]+$' THEN 'unknown'
    ELSE unaccent(
      regexp_replace(
        regexp_replace(
          LOWER(TRIM(BOTH FROM regexp_replace(seller_city, '[\\/].*$', ''))), 
          '[^a-z\s]', '', 'g'
        ),
        '\s+', ' ', 'g'
      )
    )
  END AS normalized_city
FROM bronze.olist_sellers_dataset;

--============================
-- CHECK: Products Dataset
--============================
SELECT * FROM bronze.olist_products_dataset;

-- Duplicate & nulls
SELECT product_id, COUNT(*) 
FROM bronze.olist_products_dataset 
GROUP BY product_id HAVING COUNT(*) > 1;

SELECT * FROM bronze.olist_products_dataset 
WHERE product_length_cm IS NULL;

--============================
-- CHECK: Product Translation
--============================
SELECT * FROM bronze.product_category_translation 
WHERE product_category_name IS NULL;

--============================
-- CHECK: Orders Dataset
--============================
SELECT * FROM bronze.olist_orders_dataset;

-- Duplicate and nulls
SELECT order_id, COUNT(*) 
FROM bronze.olist_orders_dataset 
GROUP BY order_id HAVING COUNT(*) > 1;

SELECT order_status FROM bronze.olist_orders_dataset WHERE order_status IS NULL;
SELECT order_purchase_timestamp FROM bronze.olist_orders_dataset WHERE order_purchase_timestamp IS NULL;

-- Invalid timestamps
SELECT * FROM bronze.olist_orders_dataset 
WHERE order_delivered_customer_date < order_purchase_timestamp;

SELECT * FROM bronze.olist_orders_dataset 
WHERE order_status = 'canceled'
  AND (
    order_approved_at IS NOT NULL OR
    order_delivered_carrier_date IS NOT NULL OR
    order_delivered_customer_date IS NOT NULL
  );

-- Negative durations
SELECT * FROM bronze.olist_orders_dataset
WHERE 
  order_approved_at < order_purchase_timestamp OR
  order_delivered_carrier_date < order_approved_at OR
  order_delivered_customer_date < order_delivered_carrier_date;

--============================
-- CHECK: Order Items Dataset
--============================
SELECT * FROM bronze.olist_order_items_dataset;

-- Nulls & logic checks
SELECT * FROM bronze.olist_order_items_dataset 
WHERE order_id IS NULL OR product_id IS NULL OR seller_id IS NULL 
  OR price IS NULL OR freight_value IS NULL;

SELECT * FROM bronze.olist_order_items_dataset 
WHERE price <= 0 OR freight_value > price;

-- Orphan checks
SELECT product_id FROM bronze.olist_order_items_dataset
EXCEPT
SELECT product_id FROM bronze.olist_products_dataset;

SELECT order_id FROM bronze.olist_order_items_dataset
EXCEPT
SELECT order_id FROM bronze.olist_orders_dataset;

SELECT seller_id FROM bronze.olist_order_items_dataset
EXCEPT
SELECT seller_id FROM bronze.olist_sellers_dataset;

-- Inconsistencies
SELECT order_id, COUNT(*) AS total_items, MAX(order_item_id) AS max_seq
FROM bronze.olist_order_items_dataset
GROUP BY order_id
HAVING COUNT(*) <> MAX(order_item_id);

--============================
-- CHECK: Order Payments Dataset
--============================
SELECT * FROM bronze.olist_order_payments_dataset;

SELECT * FROM bronze.olist_order_payments_dataset 
WHERE order_id IS NULL OR payment_sequential IS NULL 
  OR payment_type IS NULL OR payment_installments IS NULL 
  OR payment_value IS NULL;

SELECT * FROM bronze.olist_order_payments_dataset 
WHERE payment_value < 0;

-- Duplicate payment checks
SELECT order_id, payment_sequential, COUNT(*) 
FROM bronze.olist_order_payments_dataset
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- Distinct types
SELECT DISTINCT payment_type FROM bronze.olist_order_payments_dataset;

--============================
-- CHECK: Order Reviews Dataset
--============================
SELECT * FROM bronze.olist_order_reviews_dataset;

SELECT * FROM bronze.olist_order_reviews_dataset
WHERE review_id IS NULL OR order_id IS NULL OR review_score IS NULL;

-- Duplicates and inconsistencies
SELECT COUNT(*), COUNT(DISTINCT review_id) FROM bronze.olist_order_reviews_dataset;

SELECT COUNT(*)
FROM (
  SELECT order_id, COUNT(*) 
  FROM bronze.olist_order_reviews_dataset 
  GROUP BY order_id 
  HAVING COUNT(*) > 1
) AS dup_reviews;

-- Keep latest review if duplicates exist
SELECT * 
FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_creation_date DESC) AS rn
  FROM bronze.olist_order_reviews_dataset
) sub
WHERE rn = 1;

-- Invalid timestamps and scores
SELECT * FROM bronze.olist_order_reviews_dataset
WHERE review_answer_timestamp < review_creation_date;

SELECT * FROM bronze.olist_order_reviews_dataset
WHERE review_score NOT BETWEEN 1 AND 5;