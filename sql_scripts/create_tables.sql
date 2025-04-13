-- ============================================================================
-- 📁 SQL Script: create_tables.sql
-- 🔧 Purpose: Drop and recreate all necessary tables for the Olist E-commerce
--            dataset using appropriate PostgreSQL data types.
-- ============================================================================

-- Table: category_translation
DROP TABLE IF EXISTS category_translation;
CREATE TABLE category_translation (
  "product_category_name" TEXT,
  "product_category_name_english" TEXT
);

-- Table: customers
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
  "customer_id" TEXT,
  "customer_unique_id" TEXT,
  "customer_zip_code_prefix" INTEGER,
  "customer_city" TEXT,
  "customer_state" TEXT
);

-- Table: geolocation
DROP TABLE IF EXISTS geolocation;
CREATE TABLE geolocation (
  "geolocation_zip_code_prefix" INTEGER,
  "geolocation_lat" FLOAT,
  "geolocation_lng" FLOAT,
  "geolocation_city" TEXT,
  "geolocation_state" TEXT
);

-- Table: orders
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  "order_id" TEXT,
  "customer_id" TEXT,
  "order_status" TEXT,
  "order_purchase_timestamp" TEXT,
  "order_approved_at" TEXT,
  "order_delivered_carrier_date" TEXT,
  "order_delivered_customer_date" TEXT,
  "order_estimated_delivery_date" TEXT
);

-- Table: order_items
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
  "order_id" TEXT,
  "order_item_id" INTEGER,
  "product_id" TEXT,
  "seller_id" TEXT,
  "shipping_limit_date" TEXT,
  "price" FLOAT,
  "freight_value" FLOAT
);

-- Table: payments
DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
  "order_id" TEXT,
  "payment_sequential" INTEGER,
  "payment_type" TEXT,
  "payment_installments" INTEGER,
  "payment_value" FLOAT
);

-- Table: products
DROP TABLE IF EXISTS products;
CREATE TABLE products (
  "product_id" TEXT,
  "product_category_name" TEXT,
  "product_name_lenght" FLOAT,
  "product_description_lenght" FLOAT,
  "product_photos_qty" FLOAT,
  "product_weight_g" INTEGER,
  "product_length_cm" INTEGER,
  "product_height_cm" INTEGER,
  "product_width_cm" INTEGER
);

-- Table: reviews
DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
  "review_id" TEXT,
  "order_id" TEXT,
  "review_score" INTEGER,
  "review_comment_title" TEXT,
  "review_comment_message" TEXT,
  "review_creation_date" TEXT,
  "review_answer_timestamp" TEXT
);

-- Table: reviews_utf8
DROP TABLE IF EXISTS reviews_utf8;
CREATE TABLE reviews_utf8 (
  "review_id" TEXT,
  "order_id" TEXT,
  "review_score" INTEGER,
  "review_comment_title" TEXT,
  "review_comment_message" TEXT,
  "review_creation_date" TEXT,
  "review_answer_timestamp" TEXT
);

-- Table: reviews_utf8_cleaned
DROP TABLE IF EXISTS reviews_utf8_cleaned;
CREATE TABLE reviews_utf8_cleaned (
  "review_id" TEXT,
  "order_id" TEXT,
  "review_score" INTEGER,
  "review_comment_title" TEXT,
  "review_comment_message" TEXT,
  "review_creation_date" TEXT,
  "review_answer_timestamp" TEXT
);

-- Table: sellers
DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
  "seller_id" TEXT,
  "seller_zip_code_prefix" INTEGER,
  "seller_city" TEXT,
  "seller_state" TEXT
);

