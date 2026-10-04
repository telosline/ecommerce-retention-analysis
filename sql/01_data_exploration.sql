-- 01_data_exploration.sql
-- Goal: understand structure, scale and data quality of thelook_ecommerce
-- Dataset: bigquery-public-data.thelook_ecommerce (synthetic)

-- 1a. Table structure
SELECT table_name, column_name, data_type
FROM `bigquery-public-data.thelook_ecommerce.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name IN ('users', 'orders', 'order_items', 'products')
ORDER BY table_name, ordinal_position;

-- 1b. Dataset scale and period
SELECT
  COUNT(*)                 AS order_items_cnt,
  COUNT(DISTINCT order_id) AS orders_cnt,
  COUNT(DISTINCT user_id)  AS customers_cnt,
  MIN(created_at)          AS first_order_at,
  MAX(created_at)          AS last_order_at
FROM `bigquery-public-data.thelook_ecommerce.order_items`;

-- 1c. Order item statuses
-- Finding: Cancelled (~15%) and Returned (~10%) are excluded from net revenue.
SELECT
  status,
  COUNT(*)                AS items_cnt,
  ROUND(SUM(sale_price), 2) AS revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items`
GROUP BY status
ORDER BY items_cnt DESC;

-- 1d. Data quality: rows with timestamps in the future
-- Goal: check whether the dataset contains orders that have not happened yet
-- Finding: 1,582 order items are dated after the query run date
--          (2026-10-04 to 2026-10-08). The dataset is synthetic and
--          keeps generating future rows.
-- Decision: apply a fixed cutoff (created_at < '2026-10-01') in all
--           further analysis for reproducibility.
SELECT
  COUNT(*)        AS future_items_cnt,
  MIN(created_at) AS earliest_future,
  MAX(created_at) AS latest_future
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE created_at > CURRENT_TIMESTAMP();

-- 1e. Data quality: NULLs in key columns
-- Goal: make sure price, customer and product keys are always populated
-- Finding: no NULLs in sale_price, user_id or product_id
SELECT
  COUNTIF(sale_price IS NULL) AS null_price,
  COUNTIF(user_id IS NULL)    AS null_user,
  COUNTIF(product_id IS NULL) AS null_product
FROM `bigquery-public-data.thelook_ecommerce.order_items`;

-- 1f. Time coverage: orders and gross revenue by month
-- Goal: check data continuity and the general growth pattern
-- Finding: 93 consecutive months (2019-01 to 2026-09), no gaps.
--          Growth is smooth, which is typical for synthetic data.
-- Note: this is GROSS revenue (all statuses). Net revenue
--       (excluding Cancelled and Returned) is calculated in 02_revenue_overview.sql
SELECT
  DATE_TRUNC(DATE(created_at), MONTH) AS month,
  COUNT(DISTINCT order_id)            AS orders_cnt,
  ROUND(SUM(sale_price), 2)           AS gross_revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE created_at < '2026-10-01'
GROUP BY month
ORDER BY month;
