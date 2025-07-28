

-- 1. GEOLOCATION
COPY bronze.olist_geolocation_dataset
FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;

-- 2. CUSTOMERS
COPY bronze.olist_customers_dataset
FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;

-- 3. SELLERS
COPY bronze.olist_sellers_dataset
FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_sellers_dataset.csv'
DELIMITER ','
CSV HEADER;

-- 4. PRODUCTS
COPY bronze.olist_products_dataset
FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;

-- 5. PRODUCT CATEGORY TRANSLATION
COPY bronze.product_category_translation
FROM '/Users/ghazalayobi/portfolio_projects/olist/data/product_category_name_translation.csv'
DELIMITER ','
CSV HEADER;

-- 6. ORDERS
COPY bronze.olist_orders_dataset
FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;

-- 7. ORDER ITEMS
COPY bronze.olist_order_items_dataset
FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;

-- 8. ORDER PAYMENTS
COPY bronze.olist_order_payments_dataset
FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;

-- 9. ORDER REVIEWS
COPY bronze.olist_order_reviews_dataset
FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;