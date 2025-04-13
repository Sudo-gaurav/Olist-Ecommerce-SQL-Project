# Orders Table

## Initial Inspection
```sql
SELECT * FROM orders;
```

## Step 1: Remove Duplicates
```sql
DELETE FROM orders a
USING orders b
WHERE a.ctid < b.ctid
  AND a.order_id = b.order_id;
-- Deleted: 0 rows
```

## Step 2: Clean Status Column (Trim and Uppercase)
```sql
UPDATE orders
SET order_status = UPPER(TRIM(order_status));
-- Updated: 99,441 rows
```

## Step 3: Check for Null Values in Date Columns
```sql
SELECT 
    order_id, 
    order_purchase_timestamp, 
    order_approved_at, 
    order_delivered_carrier_date, 
    order_delivered_customer_date, 
    order_estimated_delivery_date
FROM orders
WHERE 
    order_purchase_timestamp IS NULL OR
    order_approved_at IS NULL OR
    order_delivered_carrier_date IS NULL OR
    order_delivered_customer_date IS NULL OR
    order_estimated_delivery_date IS NULL;

SELECT COUNT(*) AS null_value_count
FROM orders
WHERE 
    order_purchase_timestamp IS NULL OR
    order_approved_at IS NULL OR
    order_delivered_carrier_date IS NULL OR
    order_delivered_customer_date IS NULL OR
    order_estimated_delivery_date IS NULL;
-- Null values found: 2,980 rows
```

## Step 4: Change Column Types to TIMESTAMP
```sql
ALTER TABLE orders
ALTER COLUMN order_purchase_timestamp TYPE TIMESTAMP USING order_purchase_timestamp::TIMESTAMP,
ALTER COLUMN order_approved_at TYPE TIMESTAMP USING order_approved_at::TIMESTAMP,
ALTER COLUMN order_delivered_carrier_date TYPE TIMESTAMP USING order_delivered_carrier_date::TIMESTAMP,
ALTER COLUMN order_delivered_customer_date TYPE TIMESTAMP USING order_delivered_customer_date::TIMESTAMP,
ALTER COLUMN order_estimated_delivery_date TYPE TIMESTAMP USING order_estimated_delivery_date::TIMESTAMP;
```

## Step 5: Confirm Column Data Types
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'orders';
```

## Step 6: Analyze Nulls by Order Status
```sql
SELECT order_status, COUNT(*) AS count
FROM orders
WHERE order_delivered_carrier_date IS NULL 
   OR order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY count DESC;

SELECT
  order_status,
  COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL) AS carrier_date_nulls,
  COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS customer_date_nulls
FROM orders
GROUP BY order_status
ORDER BY carrier_date_nulls DESC, customer_date_nulls DESC;

SELECT 
  COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL) AS purchase_nulls,
  COUNT(*) FILTER (WHERE order_approved_at IS NULL) AS approved_nulls,
  COUNT(*) FILTER (WHERE order_estimated_delivery_date IS NULL) AS estimated_nulls
FROM orders;
```

## Step 7: Add Clean Date Columns
```sql
ALTER TABLE orders
ADD COLUMN purchase_date DATE,
ADD COLUMN approved_date DATE,
ADD COLUMN delivered_carrier_date_clean DATE,
ADD COLUMN delivered_customer_date_clean DATE,
ADD COLUMN estimated_delivery_date_clean DATE;
```

## Step 8: Populate Clean Date Columns
```sql
UPDATE orders
SET 
  purchase_date = order_purchase_timestamp::DATE,
  approved_date = order_approved_at::DATE,
  delivered_carrier_date_clean = order_delivered_carrier_date::DATE,
  delivered_customer_date_clean = order_delivered_customer_date::DATE,
  estimated_delivery_date_clean = order_estimated_delivery_date::DATE;
```

## Step 9: Drop Original Timestamp Columns
```sql
ALTER TABLE orders
DROP COLUMN order_purchase_timestamp,
DROP COLUMN order_approved_at,
DROP COLUMN order_delivered_carrier_date,
DROP COLUMN order_delivered_customer_date,
DROP COLUMN order_estimated_delivery_date;
```

## Step 10: Rename Cleaned Columns
```sql
ALTER TABLE orders RENAME COLUMN delivered_carrier_date_clean TO delivered_carrier_date;
ALTER TABLE orders RENAME COLUMN delivered_customer_date_clean TO delivered_customer_date;
ALTER TABLE orders RENAME COLUMN estimated_delivery_date_clean TO estimated_delivery_date;
```

---
All date columns have been cleaned and standardized to DATE format. The table is now optimized for dashboarding and further joins.

---

# Customers Table

## Initial Inspection
```sql
SELECT * FROM customers;
```

## Step 1: Check Column Types
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'customers';
```

## Step 2: Null Value Analysis
```sql
SELECT 
  COUNT(*) AS total_rows,
  COUNT(customer_id) AS customer_id_not_null,
  COUNT(customer_unique_id) AS customer_unique_id_not_null,
  COUNT(customer_zip_code_prefix) AS zip_code_not_null,
  COUNT(customer_city) AS city_not_null,
  COUNT(customer_state) AS state_not_null
FROM customers;
```

## Step 3: Duplicate Checks
```sql
SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT customer_unique_id, COUNT(DISTINCT customer_id) AS id_count
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT customer_id) > 1;
```

## Summary
- All `customer_id` values are unique.
- Some `customer_unique_id` values map to multiple `customer_id`s, but this is acceptable for our analysis.
- No null values found in required columns.

No cleaning necessary for this table. It is ready for use in joins and aggregations.

Absolutely! Here's the `Category Translation Table` formatted in the **same structure and style** as your `Orders Table` and `Customers Table` sections:

---

# Category Translation Table

## Initial Inspection
```sql
SELECT * FROM category_translation;
```

## Step 1: Summary Statistics
```sql
SELECT 
  COUNT(*) AS total_rows,
  COUNT(DISTINCT product_category_name) AS unique_pt_categories,
  COUNT(DISTINCT product_category_name_english) AS unique_en_categories,
  COUNT(*) - COUNT(product_category_name_english) AS missing_translations
FROM category_translation;
```
-- Verified total rows and distinct values in both language columns  
-- Checked for missing English translations

## Step 2: Check for Duplicates
```sql
SELECT product_category_name, COUNT(*) 
FROM category_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;
```
-- Ensured no duplicate `product_category_name` values exist

## Step 3: Clean and Standardize Categories
```sql
UPDATE category_translation
SET 
  product_category_name = LOWER(TRIM(product_category_name)),
  product_category_name_english = INITCAP(TRIM(product_category_name_english));
```
-- `product_category_name`: standardized to lowercase  
-- `product_category_name_english`: trimmed and capitalized

---

## Summary
- Cleaned and standardized both language columns
- No duplicates were found
- Translations are now clean and consistent
- Ready to join with the products table for dashboard-ready category names

---

Below is the formatted markdown section for your **Products Table**. You can include it in your `logs_and_notes_tables.md` file along with the other sections (Orders, Customers, Category Translation, etc.):

---

# Products Table

## Initial Inspection
```sql
SELECT * FROM products;
```

## Step 1: Check Column Names and Data Types
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'products';
```

## Step 2: Calculate Product Volume
```sql
ALTER TABLE products
ADD COLUMN product_volume INTEGER;
```

```sql
UPDATE products
SET product_volume = product_length_cm * product_width_cm * product_height_cm;
```
- *Calculated product_volume as the product of length, width, and height.*

## Step 3: Fix Column Name Typos
```sql
ALTER TABLE products 
RENAME COLUMN product_name_lenght TO product_name_length;
```

```sql
ALTER TABLE products 
RENAME COLUMN product_description_lenght TO product_description_length;
```

## Step 4: Check Data Completeness and Nulls
```sql
SELECT 
  COUNT(*) AS total_rows,
  COUNT(product_id) AS product_id_not_null,
  COUNT(product_category_name) AS category_not_null,
  COUNT(product_name_length) AS name_length_not_null
FROM products;
```

```sql
SELECT 
  COUNT(CASE WHEN product_description_length IS NOT NULL THEN 1 END) AS description_length_not_null,
  COUNT(CASE WHEN product_photos_qty IS NOT NULL THEN 1 END) AS photos_qty_not_null,
  COUNT(CASE WHEN product_weight_g IS NOT NULL THEN 1 END) AS weight_g_not_null,
  COUNT(CASE WHEN product_length_cm IS NOT NULL THEN 1 END) AS length_cm_not_null,
  COUNT(CASE WHEN product_height_cm IS NOT NULL THEN 1 END) AS height_cm_not_null,
  COUNT(CASE WHEN product_width_cm IS NOT NULL THEN 1 END) AS width_cm_not_null
FROM products;
```
- *Assesses non-null counts for key columns.*

## Step 5: Duplicate Check
```sql
SELECT product_id, COUNT(*) 
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;
```
- *Verifies that product IDs are unique.*

## Step 6: Identify Invalid Numeric Values
```sql
SELECT * FROM products
WHERE 
  product_weight_g <= 0 OR
  product_length_cm <= 0 OR
  product_height_cm <= 0 OR
  product_width_cm <= 0;
```
- *Inspects records with non-positive dimensions or weight.*

## Step 7: Clean Invalid Weight Values
```sql
UPDATE products
SET product_weight_g = NULL
WHERE product_weight_g <= 0;
```
- *Sets `product_weight_g` to NULL when invalid (<=0).*

---

## Summary
- **Product Volume Calculation:** Product volume has been computed from length, width, and height.
- **Column Name Corrections:** Fixed typos for product name and description columns.
- **Data Completeness Checks:** Verified that key columns (ID, category, name) are fully populated.
- **Duplicate and Invalid Value Checks:** Confirmed product IDs are unique and cleaned invalid weight entries.
  
The Products table is now clean and standardized, ready for further aggregations or joins in your final view.

---


# Sellers Table

## Initial Inspection
```sql
SELECT * FROM sellers;
```

## Step 1: Check Column Types
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'sellers';
```

## Step 2: Null Value Analysis
```sql
SELECT 
  COUNT(*) AS total_rows,
  COUNT(seller_id) AS seller_id_not_null,
  COUNT(seller_zip_code_prefix) AS zip_code_not_null,
  COUNT(seller_city) AS city_not_null,
  COUNT(seller_state) AS state_not_null
FROM sellers;
```
-- Ensures no critical nulls in seller metadata (IDs, city, state, etc.)

## Step 3: Duplicate Check
```sql
SELECT seller_id, COUNT(*)
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;
```
-- Confirmed all `seller_id` values are unique.

---

## Summary
- No nulls in any required columns (`seller_id`, `seller_city`, etc.)
- All seller records are unique
- Table is already clean and ready for joining with `order_items` or `products`

---


# Order Items Table

## Initial Inspection
```sql
SELECT * FROM order_items;
```

## Step 1: Check Column Types
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'order_items';
```

## Step 2: Null Value Analysis
```sql
SELECT 
  COUNT(*) AS total_rows,
  COUNT(order_id) AS order_id_not_null,
  COUNT(order_item_id) AS item_id_not_null,
  COUNT(product_id) AS product_id_not_null,
  COUNT(seller_id) AS seller_id_not_null,
  COUNT(shipping_limit_date) AS shipping_date_not_null,
  COUNT(price) AS price_not_null,
  COUNT(freight_value) AS freight_value_not_null
FROM order_items;
```
-- Validates all critical columns are non-null.

## Step 3: Duplicate Check (Composite Key)
```sql
SELECT order_id, order_item_id, COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
```
-- Ensures uniqueness across `order_id` and `order_item_id` composite key.

## Step 4: Identify Invalid Values
```sql
SELECT *
FROM order_items
WHERE price <= 0 OR freight_value < 0;
```
-- Checked for non-positive or invalid pricing values. No major issues found.

## Step 5: Convert Shipping Date to DATE Format
```sql
ALTER TABLE order_items
ADD COLUMN shipping_limit_ts TIMESTAMP;
```

```sql
UPDATE order_items
SET shipping_limit_ts = shipping_limit_date::timestamp;
```

```sql
ALTER TABLE order_items DROP COLUMN shipping_limit_date;
ALTER TABLE order_items RENAME COLUMN shipping_limit_ts TO shipping_limit_date;
```

```sql
ALTER TABLE order_items
ALTER COLUMN shipping_limit_date TYPE DATE
USING shipping_limit_date::DATE;
```
-- Reformatted shipping deadline from text to proper `DATE` type.

---

## Summary
- `order_id` + `order_item_id` form a reliable composite key with no duplicates.
- Shipping limit date has been converted and standardized.
- Price and freight values are valid and non-negative.
- Table is now clean and ready for joins and aggregation (e.g. total order value, freight).

---


# Payments Table

## Initial Inspection
```sql
SELECT * FROM payments;
```

## Step 1: Check Column Types
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'payments';
```

## Step 2: Null and Uniqueness Check
```sql
SELECT 
  COUNT(*) AS total_rows,
  COUNT(order_id) AS non_null_order_ids,
  COUNT(DISTINCT order_id) AS unique_order_ids
FROM payments;
```
-- Ensured all `order_id` values are non-null.  
-- Identified that some orders have multiple payment records.

## Step 3: Identify Duplicate Payments
```sql
SELECT order_id, COUNT(*) AS occurrence
FROM payments
GROUP BY order_id
HAVING COUNT(*) > 1;
```
-- Found ~2,961 orders with multiple payment records (installments or split methods).

## Step 4: Payment Value and Installment Summary
```sql
SELECT 
  MIN(payment_value) AS min_payment_value,
  MAX(payment_value) AS max_payment_value,
  AVG(payment_value) AS avg_payment_value,
  MIN(payment_installments) AS min_installments,
  MAX(payment_installments) AS max_installments
FROM payments;
```
-- Verified payment values and installment ranges:
- Minimum payment: 0  
- Maximum payment: 13,664.08  
- Installments: 0 to 24  

## Step 5: Validate Payments Against Orders Table
```sql
SELECT 
  COUNT(*) AS total_orders,
  COUNT(DISTINCT order_id) AS unique_orders
FROM orders;
```

```sql
SELECT  
  COUNT(*) AS total_payment_rows,
  COUNT(DISTINCT order_id) AS unique_payment_orders
FROM payments;
```

## Step 6: Find Orders Without Payments
```sql
SELECT order_id
FROM orders
EXCEPT
SELECT order_id
FROM payments;
-- Found 1 order_id without payment record
```

## Step 7: Confirm Payments Only for Valid Orders
```sql
SELECT order_id
FROM payments
EXCEPT
SELECT order_id
FROM orders;
-- No extra payment entries (All valid order IDs)
```

---

## Summary
- Detected and confirmed multiple payments per order are valid (installments or partial payments).
- 1 order was found in `orders` but missing from `payments`. It will result in `NULL` when joined.
- All other order-payment relations are intact and clean.
- Table is ready to be aggregated (SUM, AVG, etc.) and joined into the final view.

---


# Reviews Table

## Initial Inspection
```sql
SELECT * FROM reviews;
```

## Step 1: Check Column Types
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'reviews';
```

## Step 2: Null Value Analysis
```sql
SELECT 
  COUNT(*) AS total_rows,
  COUNT(order_id) AS non_null_order_ids,
  COUNT(review_score) AS non_null_review_scores,
  COUNT(review_comment_message) AS non_null_review_comments
FROM reviews;
```
-- Verified all `order_id` and `review_score` fields are populated.  
-- Nearly half of the `review_comment_message` values are missing, which is expected.

## Step 3: Duplicate Check (Multiple Reviews Per Order)
```sql
SELECT order_id, COUNT(*) AS occurrence
FROM reviews
GROUP BY order_id
HAVING COUNT(*) > 1;
```
-- Found multiple reviews per order (up to 3) for some entries.

## Step 4: Score Summary
```sql
SELECT 
  MIN(review_score) AS min_score,
  MAX(review_score) AS max_score,
  AVG(review_score) AS avg_score
FROM reviews;
```
-- Scores range from 1 to 5  
-- Average review score is approximately 4.08

## Step 5: Compare Unique Order IDs Across Tables
```sql
SELECT 'orders' AS table_name, COUNT(DISTINCT order_id) AS unique_order_ids
FROM orders
UNION ALL
SELECT 'payments' AS table_name, COUNT(DISTINCT order_id) AS unique_order_ids
FROM payments
UNION ALL
SELECT 'reviews' AS table_name, COUNT(DISTINCT order_id) AS unique_order_ids
FROM reviews;
```
-- Found:
- Orders: 99,441  
- Payments: 99,440  
- Reviews: 98,673  
-- Indicates some orders have no reviews

## Step 6: Keep Only the Latest Review Per Order
```sql
SELECT *
FROM (
  SELECT *, 
         ROW_NUMBER() OVER (
           PARTITION BY order_id 
           ORDER BY review_creation_date DESC NULLS LAST
         ) AS rn
  FROM reviews
) AS ranked_reviews
WHERE rn = 1;
```
-- Used `ROW_NUMBER()` to retain the latest review per order.

---

## Summary
- Review scores are mostly complete, with missing values in optional comment fields.
- Many orders have multiple reviews—most likely updates or duplicates.
- Latest review per order retained for final use.
- Table is ready for aggregation and joining into the final view.

---


# Geolocation Table

## Initial Inspection
```sql
SELECT * FROM geolocation;
```

## Step 1: Check Column Types
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'geolocation';
```

## Step 2: Unique Value Analysis
```sql
SELECT 
  COUNT(*) AS total_rows,
  COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_prefixes,
  COUNT(DISTINCT geolocation_lat) AS unique_latitudes,
  COUNT(DISTINCT geolocation_lng) AS unique_longitudes,
  COUNT(DISTINCT geolocation_city) AS unique_cities,
  COUNT(DISTINCT geolocation_state) AS unique_states
FROM geolocation;
```
-- Checked data distribution and coverage across location-related attributes.

## Step 3: Duplicate Check (Row-Level)
```sql
SELECT 
  COUNT(*) - COUNT(DISTINCT *) AS duplicate_rows
FROM geolocation;
```

### Alternative: Full Column-Based Duplicate Check
```sql
SELECT 
  COUNT(*) - COUNT(DISTINCT CONCAT(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)) AS duplicate_rows
FROM geolocation;
```
-- Found ~261,831 exact duplicate rows based on full column match.  
-- Could be left as-is depending on whether precision matching or city mapping is the goal.

---

## Summary
- Table contains granular latitude/longitude data per zip code prefix, often repeated.
- Used for mapping or enriching customer/seller data by region.
- Duplicates were **not removed** to preserve richness of raw geographic data.
- This table is typically used for optional enrichment, not core joins.

---

