CREATE TABLE "geolocation" (
  "geolocation_zip_code_prefix" varchar,
  "geolocation_lat" float,
  "geolocation_lng" float,
  "geolocation_city" varchar,
  "geolocation_state" varchar
);

CREATE TABLE "customers" (
  "customer_id" varchar PRIMARY KEY,
  "customer_unique_id" varchar,
  "customer_zip_code_prefix" varchar,
  "customer_city" varchar,
  "customer_state" varchar
);

CREATE TABLE "sellers" (
  "seller_id" varchar PRIMARY KEY,
  "seller_zip" varchar,
  "seller_city" varchar,
  "seller_state" varchar
);

CREATE TABLE "products" (
  "product_id" varchar PRIMARY KEY,
  "product_category_name" varchar,
  "product_name_length" int,
  "product_description_length" int,
  "product_photos_qty" int,
  "product_weight_g" int,
  "product_length_cm" int,
  "product_height_cm" int,
  "product_width_cm" int
);

CREATE TABLE "product_category_name_translation" (
  "product_category_name" varchar PRIMARY KEY,
  "product_category_name_english" varchar
);

CREATE TABLE "orders" (
  "order_id" varchar PRIMARY KEY,
  "customer_id" varchar,
  "order_status" varchar,
  "order_purchase_timestamp" datetime,
  "order_approved_at" datetime,
  "order_delivered_carrier_date" datetime,
  "order_delivered_customer_date" datetime,
  "order_estimated_delivery_date" datetime
);

CREATE TABLE "order_items" (
  "order_id" varchar,
  "order_item_id" int,
  "product_id" varchar,
  "seller_id" varchar,
  "shipping_limit_date" datetime,
  "price" float,
  "freight_value" float,
  PRIMARY KEY ("order_id", "order_item_id")
);

CREATE TABLE "order_payments" (
  "order_id" varchar,
  "payment_sequential" int,
  "payment_type" varchar,
  "payment_installments" int,
  "payment_value" float,
  PRIMARY KEY ("order_id", "payment_sequential")
);

CREATE TABLE "order_reviews" (
  "review_id" varchar PRIMARY KEY,
  "order_id" varchar,
  "review_score" int,
  "review_comment_title" varchar,
  "review_comment_message" varchar,
  "review_creation_date" datetime,
  "review_answer_timestamp" datetime
);

ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");

ALTER TABLE "order_items" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id");

ALTER TABLE "order_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id");

ALTER TABLE "order_items" ADD FOREIGN KEY ("seller_id") REFERENCES "sellers" ("seller_id");

ALTER TABLE "order_payments" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id");

ALTER TABLE "order_reviews" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id");

ALTER TABLE "customers" ADD FOREIGN KEY ("customer_zip_code_prefix") REFERENCES "geolocation" ("geolocation_zip_code_prefix");

ALTER TABLE "sellers" ADD FOREIGN KEY ("seller_zip") REFERENCES "geolocation" ("geolocation_zip_code_prefix");

ALTER TABLE "products" ADD FOREIGN KEY ("product_category_name") REFERENCES "product_category_name_translation" ("product_category_name");
