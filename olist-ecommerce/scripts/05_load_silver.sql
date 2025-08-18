/*
===============================================================================
Silver Schema – Data Loading
===============================================================================
Script Purpose:
    Loads cleaned and standardized data into the Silver Layer from the Bronze Layer.
    - Performs full refresh using TRUNCATE
    - Tracks progress and duration using RAISE NOTICE
    - Includes error handling for each table
===============================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE 
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
BEGIN
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '==========================================';
    batch_start_time := clock_timestamp();

    -- Geolocation Table
    BEGIN
        RAISE NOTICE 'Loading: Geolocation Table';
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.geolocation CASCADE;
        INSERT INTO silver.geolocation (
            zip_code_prefix,
            lat,
            lng,
            city,
            state,
            dwh_create_date
        )
        SELECT
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            CASE
                WHEN lower(trim(geolocation_city)) = 'sp' AND geolocation_state = 'SP' THEN 'sao paulo'
                WHEN lower(trim(geolocation_city)) = 'rj' AND geolocation_state = 'RJ' THEN 'rio de janeiro'
                WHEN lower(trim(geolocation_city)) = 'bh' AND geolocation_state = 'MG' THEN 'belo horizonte'
                WHEN regexp_replace(geolocation_city, '[\\/].*$', '') ~ '^[0-9\s]+$' THEN 'unknown'
                WHEN lower(unaccent(trim(geolocation_city))) = '4o centenario' THEN '4º centenario'
                ELSE unaccent(
                    regexp_replace(
                        regexp_replace(
                            lower(trim(both from regexp_replace(geolocation_city, '[\\/].*$', ''))),
                            '[^a-z\s]', '',
                            'g'
                        ),
                        '\s+', ' ',
                        'g'
                    )
                )
            END AS city,
            UPPER(trim(geolocation_state)) AS state,
            CURRENT_TIMESTAMP AS dwh_create_date
        FROM bronze.olist_geolocation_dataset;
        end_time := clock_timestamp();
        RAISE NOTICE 'Geolocation Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading GEOLOCATION: %', SQLERRM;
    END;

    -- Customers Table
    BEGIN
        RAISE NOTICE 'Loading: Customers Table';
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.customers CASCADE;
        INSERT INTO silver.customers (
            customer_id,
            unique_id,
            zip_code_prefix,
            city,
            state,
            dwh_create_date
        )
        SELECT
            customer_id,
            customer_unique_id,
            LPAD(customer_zip_code_prefix::text, 5, '0') AS zip_code_prefix,
            CASE
                WHEN lower(trim(customer_city)) = 'sp' AND customer_state = 'SP' THEN 'sao paulo'
                WHEN lower(trim(customer_city)) = 'rj' AND customer_state = 'RJ' THEN 'rio de janeiro'
                WHEN lower(trim(customer_city)) = 'bh' AND customer_state = 'MG' THEN 'belo horizonte'
                WHEN regexp_replace(customer_city, '[\\/].*$', '') ~ '^[0-9\s]+$' THEN 'unknown'
                WHEN lower(unaccent(trim(customer_city))) = '4o centenario' THEN '4º centenario'
                ELSE unaccent(
                    regexp_replace(
                        regexp_replace(
                            lower(trim(both from regexp_replace(customer_city, '[\\/].*$', ''))),
                            '[^a-z\s]', '',
                            'g'
                        ),
                        '\s+', ' ',
                        'g'
                    )
                )
            END AS city,
            UPPER(trim(customer_state)) AS state,
            CURRENT_TIMESTAMP AS dwh_create_date
        FROM bronze.olist_customers_dataset;
        end_time := clock_timestamp();
        RAISE NOTICE 'Customers Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading CUSTOMERS: %', SQLERRM;
    END;

    -- Sellers Table
    BEGIN
        RAISE NOTICE 'Loading: Sellers Table';
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.sellers CASCADE;
        INSERT INTO silver.sellers (
            seller_id,
            zip_code_prefix,
            city,
            state,
            dwh_create_date
        )
        SELECT
            seller_id,
            LPAD(seller_zip_code_prefix::text, 5, '0') AS zip_code_prefix,
            CASE
                WHEN lower(trim(seller_city)) = 'sp' AND seller_state = 'SP' THEN 'sao paulo'
                WHEN lower(trim(seller_city)) = 'rj' AND seller_state = 'RJ' THEN 'rio de janeiro'
                WHEN lower(trim(seller_city)) = 'bh' AND seller_state = 'MG' THEN 'belo horizonte'
                WHEN regexp_replace(seller_city, '[\\/].*$', '') ~ '^[0-9\s]+$' THEN 'unknown'
                WHEN lower(unaccent(trim(seller_city))) = '4o centenario' THEN '4º centenario'
                ELSE unaccent(
                    regexp_replace(
                        regexp_replace(
                            lower(trim(both from regexp_replace(seller_city, '[\\/].*$', ''))),
                            '[^a-z\s]', '',
                            'g'
                        ),
                        '\s+', ' ',
                        'g'
                    )
                )
            END AS city,
            UPPER(trim(seller_state)) AS state,
            CURRENT_TIMESTAMP AS dwh_create_date
        FROM bronze.olist_sellers_dataset;
        end_time := clock_timestamp();
        RAISE NOTICE 'Sellers Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading SELLERS: %', SQLERRM;
    END;

    -- Products Table
    BEGIN
        RAISE NOTICE 'Loading: Products Table';
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.products CASCADE;
        INSERT INTO silver.products (
            product_id,
            category_name,
            name_length,
            description_length,
            photos_qty,
            weight_g,
            length_cm,
            height_cm,
            width_cm,
            dwh_create_date
        )
        SELECT 
            product_id,
            product_category_name,
            product_name_length,
            product_description_length,
            product_photos_qty,
            product_weight_g,
            product_length_cm,
            product_height_cm,
            product_width_cm,
            CURRENT_TIMESTAMP
        FROM bronze.olist_products_dataset
        WHERE product_category_name IS NOT NULL;
        end_time := clock_timestamp();
        RAISE NOTICE 'Products Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading PRODUCTS: %', SQLERRM;
    END;

    -- Product Category Translation Table
    BEGIN
        RAISE NOTICE 'Loading: Product Category Name Translation Table';
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.product_category_translation CASCADE;
        INSERT INTO silver.product_category_translation (
            category_name,
            category_name_english,
            dwh_create_date
        )
        SELECT
            product_category_name,
            product_category_name_english,
            CURRENT_TIMESTAMP
        FROM bronze.product_category_translation;
        end_time := clock_timestamp();
        RAISE NOTICE 'Category Translation Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading PRODUCT CATEGORY TRANSLATION: %', SQLERRM;
    END;

    -- Orders Table
    BEGIN
        RAISE NOTICE 'Loading: Orders Table';
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.orders;
        INSERT INTO silver.orders (
            order_id,
            customer_id,
            status,
            purchase_timestamp,
            approved_at,
            delivered_carrier_date,
            delivered_customer_date,
            estimated_delivery_date,
            dwh_create_date
        )
        SELECT
            order_id,
            customer_id,
            LOWER(TRIM(order_status)),
            order_purchase_timestamp::timestamp,
            CASE WHEN order_approved_at >= order_purchase_timestamp THEN order_approved_at ELSE NULL END,
            CASE WHEN order_delivered_carrier_date >= order_approved_at THEN order_delivered_carrier_date ELSE NULL END,
            CASE WHEN order_delivered_customer_date >= order_delivered_carrier_date THEN order_delivered_customer_date ELSE NULL END,
            order_estimated_delivery_date::timestamp,
            CURRENT_TIMESTAMP
        FROM bronze.olist_orders_dataset
        WHERE order_purchase_timestamp IS NOT NULL;

        -- Add derived columns
        ALTER TABLE silver.orders ADD COLUMN IF NOT EXISTS delivery_time INTERVAL;
        UPDATE silver.orders
        SET delivery_time = JUSTIFY_INTERVAL(delivered_customer_date - purchase_timestamp)
        WHERE delivered_customer_date IS NOT NULL AND purchase_timestamp IS NOT NULL;

        ALTER TABLE silver.orders ADD COLUMN IF NOT EXISTS row_flag TEXT;
        UPDATE silver.orders
        SET row_flag = CASE
            WHEN status = 'canceled' AND (
                approved_at IS NOT NULL OR 
                delivered_carrier_date IS NOT NULL OR 
                delivered_customer_date IS NOT NULL
            ) THEN 'invalid'
            WHEN approved_at < purchase_timestamp
                OR delivered_carrier_date < approved_at
                OR delivered_customer_date < delivered_carrier_date
            THEN 'invalid'
            ELSE 'valid'
        END;
        end_time := clock_timestamp();
        RAISE NOTICE 'Orders Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading ORDERS: %', SQLERRM;
    END;

    -- Order Items Table
    BEGIN
        RAISE NOTICE 'Loading: Order Items Table';
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.order_items;
        INSERT INTO silver.order_items (
            order_id,
            item_id,
            product_id,
            seller_id,
            shipping_limit_date,
            price,
            freight_value,
            dwh_create_date
        )
        SELECT
            order_id,
            order_item_id,
            product_id,
            seller_id,
            shipping_limit_date,
            price,
            freight_value,
            CURRENT_TIMESTAMP
        FROM bronze.olist_order_items_dataset
        WHERE order_id IS NOT NULL
          AND product_id IS NOT NULL
          AND seller_id IS NOT NULL
          AND price > 0
          AND freight_value >= 0;
        end_time := clock_timestamp();
        RAISE NOTICE 'Order Items Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading ORDER ITEMS: %', SQLERRM;
    END;

    -- Order Payments Table
    BEGIN
        RAISE NOTICE 'Loading: Order Payments Table';
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.order_payments ;
        INSERT INTO silver.order_payments (
            order_id,
            sequential,
            type,
            installments,
            value,
            dwh_create_date
        )
        SELECT
            order_id,
            payment_sequential,
            LOWER(TRIM(payment_type)),
            payment_installments,
            payment_value,
            CURRENT_TIMESTAMP
        FROM bronze.olist_order_payments_dataset
        WHERE order_id IS NOT NULL
          AND payment_sequential IS NOT NULL
          AND payment_type IS NOT NULL
          AND payment_installments IS NOT NULL
          AND payment_value IS NOT NULL
          AND payment_value >= 0;
        end_time := clock_timestamp();
        RAISE NOTICE 'Order Payments Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading ORDER PAYMENTS: %', SQLERRM;
    END;

    -- Order Reviews Table
    BEGIN
        RAISE NOTICE 'Loading: Order Reviews Table';
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.order_reviews;
        INSERT INTO silver.order_reviews (
            review_id,
            order_id,
            score,
            comment_title,
            comment_message,
            creation_date,
            answer_timestamp,
            dwh_create_date
        )
        SELECT 
            review_id,
            order_id,
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date,
            review_answer_timestamp,
            CURRENT_TIMESTAMP
        FROM (
            SELECT *,
                ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_creation_date DESC) AS rn
            FROM bronze.olist_order_reviews_dataset
            WHERE review_id IS NOT NULL
              AND order_id IS NOT NULL
              AND review_score IS NOT NULL
        ) sub
        WHERE rn = 1;
        end_time := clock_timestamp();
        RAISE NOTICE 'Order Reviews Load Time: %', end_time - start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading ORDER REVIEWS: %', SQLERRM;
    END;

    batch_end_time := clock_timestamp();
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Silver Layer Total Load Duration: %', batch_end_time - batch_start_time;
    RAISE NOTICE '==========================================';
END;
$$;