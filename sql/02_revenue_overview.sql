-- 02_revenue_overview.sql
-- Net revenue = all order items except Cancelled and Returned
-- Data cutoff: created_at < '2026-10-01'

-- 2a. Monthly net revenue, orders and average order value
SELECT
  DATE_TRUNC(DATE(created_at), MONTH)                  AS month,
  COUNT(DISTINCT order_id)                             AS orders_cnt,
  ROUND(SUM(sale_price), 2)                            AS net_revenue,
  ROUND(SUM(sale_price) / COUNT(DISTINCT order_id), 2) AS aov
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE created_at < '2026-10-01'
  AND status NOT IN ('Cancelled', 'Returned')
GROUP BY month
ORDER BY month;

-- 2b. Yearly net revenue and growth vs previous year
-- Note: 2026 has only 9 months, so its growth looks lower than it really is
-- (see 2c for a fair comparison)
WITH yearly AS (
  SELECT
    EXTRACT(YEAR FROM created_at) AS year,
    COUNT(DISTINCT order_id)      AS orders_cnt,
    ROUND(SUM(sale_price), 2)     AS net_revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE created_at < '2026-10-01'
    AND status NOT IN ('Cancelled', 'Returned')
  GROUP BY year
)
SELECT
  year,
  orders_cnt,
  net_revenue,
  ROUND(SAFE_DIVIDE(
    net_revenue - LAG(net_revenue) OVER (ORDER BY year),
    LAG(net_revenue) OVER (ORDER BY year)) * 100, 1) AS yoy_growth_pct
FROM yearly
ORDER BY year;

-- 2c. Year-over-year growth, January to September only (like-for-like)
-- Compares the same 9 months in every year, so 2026 is not penalised for being incomplete
WITH ytd AS (
  SELECT
    EXTRACT(YEAR FROM created_at) AS year,
    COUNT(DISTINCT order_id)      AS orders_cnt,
    ROUND(SUM(sale_price), 2)     AS net_revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE created_at < '2026-10-01'
    AND EXTRACT(MONTH FROM created_at) <= 9
    AND status NOT IN ('Cancelled', 'Returned')
  GROUP BY year
)
SELECT
  year,
  orders_cnt,
  net_revenue,
  ROUND(SAFE_DIVIDE(
    net_revenue - LAG(net_revenue) OVER (ORDER BY year),
    LAG(net_revenue) OVER (ORDER BY year)) * 100, 1) AS yoy_growth_pct
FROM ytd
ORDER BY year;
