
/*
===============================================================================
Silver Schema – Table Definition Script
===============================================================================
Script Purpose:
    This script defines the structure of all tables in the 'Silver' schema.
    It drops existing tables (if they exist) before creating them anew.
    - adding a new column to each table to track its creation date 
    
===============================================================================
*/

-- Create schema 
CREATE SCHEMA IF NOT EXISTS silver;

-- =========================
-- 1. GEOLOCATION
-- =========================
DROP TABLE IF EXISTS silver.geolocation CASCADE;
CREATE TABLE silver.geolocation (
  zip_code_prefix VARCHAR(9),
  lat NUMERIC(9,6),
  lng NUMERIC(9,6),
  city VARCHAR(100),
  state VARCHAR(10),
  dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 2. CUSTOMERS
-- =========================
DROP TABLE IF EXISTS silver.customers CASCADE;
CREATE TABLE silver.customers (
  customer_id VARCHAR(50) PRIMARY KEY,
  unique_id VARCHAR(50),
  zip_code_prefix VARCHAR(9),
  city VARCHAR(100),
  state VARCHAR(10),
  dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 3. SELLERS
-- =========================
DROP TABLE IF EXISTS silver.sellers CASCADE;
CREATE TABLE silver.sellers (
  seller_id VARCHAR(50) PRIMARY KEY,
  zip_code_prefix VARCHAR(9),
  city VARCHAR(100),
  state VARCHAR(10), 
  dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 4. PRODUCTS
-- =========================
DROP TABLE IF EXISTS silver.products CASCADE;
CREATE TABLE silver.products (
  product_id VARCHAR(50) PRIMARY KEY,
  category_name VARCHAR(100),
  name_length INT,
  description_length INT,
  photos_qty INT,
  weight_g INT,
  length_cm INT,
  height_cm INT,
  width_cm INT,
  dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 5. PRODUCT CATEGORY TRANSLATION
-- =========================
DROP TABLE IF EXISTS silver.product_category_translation CASCADE;
CREATE TABLE silver.product_category_translation (
  category_name VARCHAR(100) PRIMARY KEY,
  category_name_english VARCHAR(100),
  dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 6. ORDERS
-- =========================
DROP TABLE IF EXISTS silver.orders CASCADE;
CREATE TABLE silver.orders (
  order_id CHAR(32) PRIMARY KEY,
  customer_id VARCHAR(50),
  status VARCHAR(50),
  purchase_timestamp TIMESTAMP,
  approved_at TIMESTAMP,
  delivered_carrier_date TIMESTAMP,
  delivered_customer_date TIMESTAMP,
  estimated_delivery_date TIMESTAMP,
  dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 7. ORDER ITEMS
-- =========================
DROP TABLE IF EXISTS silver.order_items CASCADE;
CREATE TABLE silver.order_items (
  order_id CHAR(32),
  item_id INT,
  product_id VARCHAR(50),
  seller_id VARCHAR(50),
  shipping_limit_date TIMESTAMP,
  price NUMERIC(10,2),
  freight_value NUMERIC(10,2),
  PRIMARY KEY (order_id, item_id),
  dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================
-- 8. ORDER PAYMENTS
-- =========================
DROP TABLE IF EXISTS silver.order_payments CASCADE;
CREATE TABLE silver.order_payments (
  order_id CHAR(32),
  sequential INT,
  type VARCHAR(50),
  installments INT,
  value NUMERIC(10,2),
  PRIMARY KEY (order_id, sequential),
  dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 9. ORDER REVIEWS
-- =========================
DROP TABLE IF EXISTS silver.order_reviews CASCADE;
CREATE TABLE silver.order_reviews (
  review_id VARCHAR(50),
  order_id CHAR(32),
  score INT,
  comment_title VARCHAR(200),
  comment_message TEXT,
  creation_date TIMESTAMP,
  answer_timestamp TIMESTAMP,
  dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);