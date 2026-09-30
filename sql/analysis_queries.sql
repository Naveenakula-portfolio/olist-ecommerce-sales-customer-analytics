-- Olist E-commerce Analytics Project
-- SQLite dialect. Load CSVs into tables named below before running.
-- IMPORTANT: Aggregate order_items/payments/reviews separately before joining to avoid row multiplication.

-- 1. Overall order status distribution
SELECT order_status, COUNT(*) AS orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- 2. Delivered orders by month
SELECT strftime('%Y-%m', order_purchase_timestamp) AS purchase_month,
       COUNT(*) AS delivered_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY strftime('%Y-%m', order_purchase_timestamp)
ORDER BY purchase_month;

-- 3. Item value by product category (delivered orders only)
SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       ROUND(SUM(oi.price), 2) AS item_value_brl,
       COUNT(DISTINCT oi.order_id) AS orders
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN category_translation t ON t.product_category_name = p.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY item_value_brl DESC;

-- 4. Top 10 product categories by item value
SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       ROUND(SUM(oi.price), 2) AS item_value_brl
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN category_translation t ON t.product_category_name = p.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY item_value_brl DESC
LIMIT 10;

-- 5. Delivered orders by customer state
SELECT c.customer_state, COUNT(DISTINCT o.order_id) AS delivered_orders
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY delivered_orders DESC;

-- 6. Total payment value by payment type
SELECT payment_type, ROUND(SUM(payment_value), 2) AS payment_value_brl,
       COUNT(*) AS payment_records
FROM order_payments
GROUP BY payment_type
ORDER BY payment_value_brl DESC;

-- 7. Average order item value (order-level aggregation first)
WITH order_values AS (
  SELECT order_id, SUM(price) AS item_value
  FROM order_items
  GROUP BY order_id
)
SELECT ROUND(AVG(item_value), 2) AS avg_item_value_per_order_brl,
       COUNT(*) AS orders_with_items
FROM order_values;

-- 8. Delivery duration in days for delivered orders
SELECT ROUND(AVG((julianday(order_delivered_customer_date) -
                  julianday(order_purchase_timestamp))), 2) AS avg_delivery_days,
       COUNT(*) AS delivered_orders_with_delivery_timestamp
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL;

-- 9. On-time versus late delivery
SELECT
  CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
       THEN 'Late' ELSE 'On or before estimate' END AS delivery_timing,
  COUNT(*) AS delivered_orders,
  ROUND(AVG(julianday(order_delivered_customer_date) -
            julianday(order_purchase_timestamp)), 2) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_timing;

-- 10. Average review score by delivery timing (review and order aggregated separately)
WITH reviews_by_order AS (
  SELECT order_id, AVG(review_score) AS review_score
  FROM order_reviews
  GROUP BY order_id
)
SELECT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late' ELSE 'On or before estimate' END AS delivery_timing,
       ROUND(AVG(r.review_score), 2) AS avg_review_score,
       COUNT(*) AS orders_with_review
FROM orders o
JOIN reviews_by_order r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_timing;

-- 11. Review score distribution
SELECT review_score, COUNT(*) AS reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

-- 12. Low-review share by category (reviews joined through order items; item-level join means reviews can repeat for multi-item orders)
WITH order_category AS (
  SELECT DISTINCT oi.order_id,
         COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category
  FROM order_items oi
  LEFT JOIN products p ON p.product_id = oi.product_id
  LEFT JOIN category_translation t ON t.product_category_name = p.product_category_name
), reviews_by_order AS (
  SELECT order_id, AVG(review_score) AS review_score
  FROM order_reviews
  GROUP BY order_id
)
SELECT oc.category,
       COUNT(*) AS category_orders_with_review,
       ROUND(AVG(r.review_score), 2) AS avg_review_score,
       ROUND(100.0 * AVG(CASE WHEN r.review_score <= 2 THEN 1.0 ELSE 0.0 END), 2) AS pct_low_reviews
FROM order_category oc
JOIN reviews_by_order r ON r.order_id = oc.order_id
GROUP BY oc.category
HAVING COUNT(*) >= 50
ORDER BY pct_low_reviews DESC;

-- 13. Repeat customer analysis using customer_unique_id
WITH customer_orders AS (
  SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS order_count
  FROM customers c
  JOIN orders o ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
)
SELECT COUNT(*) AS unique_customers,
       SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * AVG(CASE WHEN order_count > 1 THEN 1.0 ELSE 0.0 END), 2) AS pct_repeat_customers
FROM customer_orders;

-- 14. Seller locations (state/city) with the highest delivered item value
SELECT s.seller_state, s.seller_city,
       ROUND(SUM(oi.price), 2) AS item_value_brl,
       COUNT(DISTINCT oi.order_id) AS orders
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN sellers s ON s.seller_id = oi.seller_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state, s.seller_city
ORDER BY item_value_brl DESC
LIMIT 10;

-- 15. Payment installments distribution
SELECT payment_installments, COUNT(*) AS payment_records,
       ROUND(SUM(payment_value), 2) AS payment_value_brl
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;

-- 16. Monthly item value for delivered orders
SELECT strftime('%Y-%m', o.order_purchase_timestamp) AS purchase_month,
       ROUND(SUM(oi.price), 2) AS item_value_brl
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY strftime('%Y-%m', o.order_purchase_timestamp)
ORDER BY purchase_month;

-- 17. Product metadata completeness
SELECT COUNT(*) AS products,
       SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS missing_category,
       SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS missing_weight,
       SUM(CASE WHEN product_length_cm IS NULL OR product_height_cm IS NULL OR product_width_cm IS NULL
                THEN 1 ELSE 0 END) AS missing_any_dimension
FROM products;

-- 18. Window function: monthly delivered order count and previous month comparison
WITH monthly AS (
  SELECT strftime('%Y-%m', order_purchase_timestamp) AS purchase_month,
         COUNT(*) AS delivered_orders
  FROM orders
  WHERE order_status = 'delivered'
  GROUP BY strftime('%Y-%m', order_purchase_timestamp)
)
SELECT purchase_month, delivered_orders,
       LAG(delivered_orders) OVER (ORDER BY purchase_month) AS previous_month_orders,
       delivered_orders - LAG(delivered_orders) OVER (ORDER BY purchase_month) AS change_vs_previous_month
FROM monthly
ORDER BY purchase_month;

-- 19. CTE + window function: rank product categories by delivered item value
WITH category_sales AS (
  SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
         SUM(oi.price) AS item_value_brl
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  LEFT JOIN products p ON p.product_id = oi.product_id
  LEFT JOIN category_translation t ON t.product_category_name = p.product_category_name
  WHERE o.order_status = 'delivered'
  GROUP BY category
)
SELECT category, ROUND(item_value_brl, 2) AS item_value_brl,
       DENSE_RANK() OVER (ORDER BY item_value_brl DESC) AS sales_rank
FROM category_sales
ORDER BY sales_rank;

-- 20. Order approval delay (hours)
SELECT ROUND(AVG((julianday(order_approved_at) -
                  julianday(order_purchase_timestamp)) * 24), 2) AS avg_approval_delay_hours,
       COUNT(*) AS orders_with_both_timestamps
FROM orders
WHERE order_approved_at IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL;
