-- ============================================================================
-- 🧾 View: final_detailed_view
--  Description: Combines cleaned and aggregated data from orders, customers, payments, reviews, products, and categories into a single articulated table for reporting and dashboarding.
-- ============================================================================

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
    -- 📦 Delivery metrics
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

-- 📊 Final Aggregated Output
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

-- 🔍 Preview Table (optional testing)
SELECT * FROM final_detailed_view
ORDER BY purchase_date;
