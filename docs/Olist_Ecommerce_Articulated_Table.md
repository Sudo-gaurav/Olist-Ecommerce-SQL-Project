# Olist_Ecommerce_Articulated_Table.md

This document provides the final SQL view definitions that integrate and aggregate data from the Brazilian E-commerce Public Dataset by Olist. It demonstrates the cleaning, transformation, and integration process resulting in a single articulated table that combines order, customer, payment, review, and order items information. This view is designed for further analysis and dashboarding.

---

## (View) base_orders Table

The **base_orders** view brings together key order-level data from the `orders` table along with corresponding customer information from the `customers` table.

```sql
CREATE OR REPLACE VIEW base_orders AS
SELECT o.order_id,
       o.purchase_date,
       o.approved_date,
       o.delivered_carrier_date,
       o.delivered_customer_date,
       o.estimated_delivery_date,
       c.customer_id,
       c.customer_zip_code_prefix,
       c.customer_city,
       c.customer_state
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id;
```

---

## (View) Final Detailed View Table

The **final_detailed_view** aggregates data from multiple sources and includes computed delivery metrics along with aggregated payment, review, and order items data. This view forms a comprehensive, articulated table at the order level.

```sql
CREATE VIEW final_detailed_view AS
WITH bo AS (
  SELECT 
    o.order_id,
    o.purchase_date,
    o.approved_date,
    o.delivered_carrier_date,
    o.delivered_customer_date,
    o.estimated_delivery_date,
    c.customer_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state,
    -- Calculate delivery metrics:
    (o.delivered_customer_date - o.purchase_date) AS delivery_time_days,
    (o.delivered_customer_date - o.estimated_delivery_date) AS delivery_delay_days
  FROM orders o
  LEFT JOIN customers c ON o.customer_id = c.customer_id
),
pa AS (
  SELECT 
    order_id,
    SUM(payment_value) AS total_payment,
    MIN(payment_installments) AS min_installments,
    MAX(payment_installments) AS max_installments,
    COUNT(*) AS payment_count
  FROM payments
  GROUP BY order_id
),
ra AS (
  SELECT 
    order_id,
    AVG(review_score) AS avg_review_score,
    COUNT(*) AS review_count
  FROM reviews
  GROUP BY order_id
),
oi AS (
  SELECT 
    oi.order_id,
    COUNT(*) AS total_items,
    SUM(oi.price) AS total_item_price,
    SUM(oi.freight_value) AS total_freight_value,
    STRING_AGG(DISTINCT oi.product_id, ', ') AS product_ids,
    STRING_AGG(DISTINCT ct.product_category_name_english, ', ') AS product_categories_english,
    STRING_AGG(DISTINCT CAST(p.product_volume AS TEXT), ', ') AS product_volumes
  FROM order_items oi
  LEFT JOIN products p ON oi.product_id = p.product_id
  LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
  GROUP BY oi.order_id
)
SELECT 
  bo.order_id,
  bo.purchase_date,
  bo.approved_date,
  bo.delivered_carrier_date,
  bo.delivered_customer_date,
  bo.estimated_delivery_date,
  bo.delivery_time_days,
  bo.delivery_delay_days,
  bo.customer_id,
  bo.customer_zip_code_prefix,
  bo.customer_city,
  bo.customer_state,
  pa.total_payment,
  pa.min_installments,
  pa.max_installments,
  pa.payment_count,
  ra.avg_review_score,
  ra.review_count,
  oi.total_items,
  oi.total_item_price,
  oi.total_freight_value,
  oi.product_ids,
  oi.product_categories_english,
  oi.product_volumes
FROM bo
LEFT JOIN pa ON bo.order_id = pa.order_id
LEFT JOIN ra ON bo.order_id = ra.order_id
LEFT JOIN oi ON bo.order_id = oi.order_id;
```

### Testing the Final View
To ensure everything is working as expected, run:
```sql
SELECT * FROM final_detailed_view;
```
This should return 99,441 rows (one per order) with comprehensive aggregated metrics.

---

## Final Notes

- **Process Documentation:** Detailed cleaning and transformation logs for each table (Orders, Customers, Products, etc.) are documented in separate files (e.g., `logs_and_notes_tables.md`). This file outlines the complete process and demonstrates SQL capabilities.
  
- **Flexibility:**  
  With this final articulated table in place, you have a rich dataset to use directly in dashboards or to further enhance with DAX calculations (e.g., delivery status, repeat customer flags) later.

- **Repository Organization:**  
  It is recommended to maintain a clear folder structure in your GitHub repository—separating:
  - Final view scripts (in `sql_scripts/`),
  - Process logs (`docs/logs_and_notes_tables.md`), and
  - Sample data if required (`data/`).

---
*End of Olist_Ecommerce_Articulated_Table.md*
