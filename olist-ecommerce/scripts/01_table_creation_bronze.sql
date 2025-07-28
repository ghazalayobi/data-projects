/*
===============================================================================
Bronze Schema – Table Definition Script
===============================================================================
Script Purpose:
    This script defines the structure of all tables in the 'bronze' schema.
    It drops existing tables (if they exist) before creating them anew.
    
    
===============================================================================
*/



-- Create schema 
CREATE SCHEMA IF NOT EXISTS bronze;

-- =========================
-- 1. GEOLOCATION
-- =========================
DROP TABLE IF EXISTS bronze.olist_geolocation_dataset CASCADE;
CREATE TABLE bronze.olist_geolocation_dataset (
  geolocation_zip_code_prefix VARCHAR(20),
  geolocation_lat NUMERIC,
  geolocation_lng NUMERIC,
  geolocation_city VARCHAR(100),
  geolocation_state VARCHAR(10)
);

-- =========================
-- 2. CUSTOMERS
-- =========================
DROP TABLE IF EXISTS bronze.olist_customers_dataset CASCADE;
CREATE TABLE bronze.olist_customers_dataset (
  customer_id VARCHAR(50) PRIMARY KEY,
  customer_unique_id VARCHAR(50),
  customer_zip_code_prefix VARCHAR(20),
  customer_city VARCHAR(100),
  customer_state VARCHAR(10)
);

-- =========================
-- 3. SELLERS
-- =========================
DROP TABLE IF EXISTS bronze.olist_sellers_dataset CASCADE;
CREATE TABLE bronze.olist_sellers_dataset (
  seller_id VARCHAR(50) PRIMARY KEY,
  seller_zip_code_prefix VARCHAR(20),
  seller_city VARCHAR(100),
  seller_state VARCHAR(10)
);

-- =========================
-- 4. PRODUCTS
-- =========================
DROP TABLE IF EXISTS bronze.olist_products_dataset CASCADE;
CREATE TABLE bronze.olist_products_dataset (
  product_id VARCHAR(50) PRIMARY KEY,
  product_category_name VARCHAR(100),
  product_name_length INT,
  product_description_length INT,
  product_photos_qty INT,
  product_weight_g INT,
  product_length_cm INT,
  product_height_cm INT,
  product_width_cm INT
);

-- =========================
-- 5. PRODUCT CATEGORY TRANSLATION
-- =========================
DROP TABLE IF EXISTS bronze.product_category_translation CASCADE;
CREATE TABLE bronze.product_category_translation (
  product_category_name VARCHAR(100) PRIMARY KEY,
  product_category_name_english VARCHAR(100)
);

-- =========================
-- 6. ORDERS
-- =========================
DROP TABLE IF EXISTS bronze.olist_orders_dataset CASCADE;
CREATE TABLE bronze.olist_orders_dataset (
  order_id VARCHAR(50) PRIMARY KEY,
  customer_id VARCHAR(50),
  order_status VARCHAR(50),
  order_purchase_timestamp TIMESTAMP,
  order_approved_at TIMESTAMP,
  order_delivered_carrier_date TIMESTAMP,
  order_delivered_customer_date TIMESTAMP,
  order_estimated_delivery_date TIMESTAMP
);

-- =========================
-- 7. ORDER ITEMS
-- =========================
DROP TABLE IF EXISTS bronze.olist_order_items_dataset CASCADE;
CREATE TABLE bronze.olist_order_items_dataset (
  order_id VARCHAR(50),
  order_item_id INT,
  product_id VARCHAR(50),
  seller_id VARCHAR(50),
  shipping_limit_date TIMESTAMP,
  price NUMERIC(10,2),
  freight_value NUMERIC(10,2),
  PRIMARY KEY (order_id, order_item_id)
);

-- =========================
-- 8. ORDER PAYMENTS
-- =========================
DROP TABLE IF EXISTS bronze.olist_order_payments_dataset CASCADE;
CREATE TABLE bronze.olist_order_payments_dataset (
  order_id VARCHAR(50),
  payment_sequential INT,
  payment_type VARCHAR(50),
  payment_installments INT,
  payment_value NUMERIC(10,2),
  PRIMARY KEY (order_id, payment_sequential)
);

-- =========================
-- 9. ORDER REVIEWS
-- =========================
DROP TABLE IF EXISTS bronze.olist_order_reviews_dataset CASCADE;
CREATE TABLE bronze.olist_order_reviews_dataset (
  review_id VARCHAR(50),
  order_id VARCHAR(50),
  review_score INT,
  review_comment_title VARCHAR(200),
  review_comment_message TEXT,
  review_creation_date TIMESTAMP,
  review_answer_timestamp TIMESTAMP
);



