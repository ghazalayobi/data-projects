
/*
===============================================================================
Bronze Schema – Data Loading
===============================================================================
Script Purpose:
    This stored procedure loads raw (bronze layer) data
    from CSV files on the local file system into staging tables
    within the 'bronze' schema. It includes:
	- TRUNCATE for full refresh
	- COPY for data ingestion
	- RAISE NOTICE for timing and progress tracking
	- Error handling for each table
    
===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE 
	start_time TIMESTAMP;
	end_time TIMESTAMP;
	batch_start_time TIMESTAMP;
	batch_end_time TIMESTAMP;

BEGIN


	RAISE NOTICE '==========================================';
	RAISE NOTICE 'Loading Bronze Layer';
	RAISE NOTICE '==========================================';
	batch_start_time := clock_timestamp();
	BEGIN
		-- 1. GEOLOCATION
		RAISE NOTICE 'Loading: olist_geolocation_dataset';
		start_time := clock_timestamp();
		TRUNCATE TABLE bronze.olist_geolocation_dataset CASCADE;
		COPY bronze.olist_geolocation_dataset
		FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_geolocation_dataset.csv'
		DELIMITER ','
		CSV HEADER;
		end_time := clock_timestamp();
		RAISE NOTICE 'Geolocation Load Time: %', end_time - start_time;
	    EXCEPTION WHEN OTHERS THEN
	        RAISE WARNING 'Error loading GEOLOCATION: %', SQLERRM;
	END;

    -- 2. CUSTOMERS
    BEGIN
        RAISE NOTICE 'Loading: olist_customers_dataset';
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.olist_customers_dataset CASCADE;
        COPY bronze.olist_customers_dataset
        FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_customers_dataset.csv'
        DELIMITER ','
        CSV HEADER;
        end_time := clock_timestamp();
        RAISE NOTICE 'Customers Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading CUSTOMERS: %', SQLERRM;
    END;

    -- 3. SELLERS
    BEGIN
        RAISE NOTICE 'Loading: olist_sellers_dataset';
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.olist_sellers_dataset CASCADE;
        COPY bronze.olist_sellers_dataset
        FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_sellers_dataset.csv'
        DELIMITER ','
        CSV HEADER;
        end_time := clock_timestamp();
        RAISE NOTICE 'Sellers Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading SELLERS: %', SQLERRM;
    END;
	
	    -- 4. PRODUCTS
    RAISE NOTICE 'Loading: olist_products_dataset';
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.olist_products_dataset CASCADE;
        COPY bronze.olist_products_dataset
        FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_products_dataset.csv'
        DELIMITER ','
        CSV HEADER;
        end_time := clock_timestamp();
        RAISE NOTICE 'Products Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading PRODUCTS: %', SQLERRM;
    END;

    -- 5. PRODUCT CATEGORY TRANSLATION
    RAISE NOTICE 'Loading: product_category_translation';
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.product_category_translation CASCADE;
        COPY bronze.product_category_translation
        FROM '/Users/ghazalayobi/portfolio_projects/olist/data/product_category_name_translation.csv'
        DELIMITER ','
        CSV HEADER;
        end_time := clock_timestamp();
        RAISE NOTICE 'Category Translation Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading PRODUCT CATEGORY TRANSLATION: %', SQLERRM;
    END;

    -- 6. ORDERS
    RAISE NOTICE 'Loading: olist_orders_dataset';
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.olist_orders_dataset CASCADE;
        COPY bronze.olist_orders_dataset
        FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_orders_dataset.csv'
        DELIMITER ','
        CSV HEADER;
        end_time := clock_timestamp();
        RAISE NOTICE 'Orders Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading ORDERS: %', SQLERRM;
    END;

    -- 7. ORDER ITEMS
    RAISE NOTICE 'Loading: olist_order_items_dataset';
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.olist_order_items_dataset CASCADE;
        COPY bronze.olist_order_items_dataset
        FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_order_items_dataset.csv'
        DELIMITER ','
        CSV HEADER;
        end_time := clock_timestamp();
        RAISE NOTICE 'Order Items Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading ORDER ITEMS: %', SQLERRM;
    END;

    -- 8. ORDER PAYMENTS
    RAISE NOTICE 'Loading: olist_order_payments_dataset';
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.olist_order_payments_dataset CASCADE;
        COPY bronze.olist_order_payments_dataset
        FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_order_payments_dataset.csv'
        DELIMITER ','
        CSV HEADER;
        end_time := clock_timestamp();
        RAISE NOTICE 'Order Payments Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading ORDER PAYMENTS: %', SQLERRM;
    END;

    -- 9. ORDER REVIEWS
    RAISE NOTICE 'Loading: olist_order_reviews_dataset';
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.olist_order_reviews_dataset CASCADE;
        COPY bronze.olist_order_reviews_dataset
        FROM '/Users/ghazalayobi/portfolio_projects/olist/data/olist_order_reviews_dataset.csv'
        DELIMITER ','
        CSV HEADER;
        end_time := clock_timestamp();
        RAISE NOTICE 'Order Reviews Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading ORDER REVIEWS: %', SQLERRM;
    END;
batch_end_time := clock_timestamp();
RAISE NOTICE '==========================================';
RAISE NOTICE 'Bronze Layer Total Load Duration: %', batch_end_time - batch_start_time;
RAISE NOTICE '==========================================';

END;
$$



-- Use "CALL bronze.load_bronze()" to execute the code