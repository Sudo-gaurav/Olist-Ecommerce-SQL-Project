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

select* from base_orders 
