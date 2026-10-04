-- 3a. Customers and net revenue by traffic source
-- 3a result: Search brings about 70% of users and about 70% of net revenue.
-- Buyer rate (about 65%) and revenue per buyer (about 120) are almost the same
-- for all five channels, so customer quality does not differ much between channels.
-- There is no marketing cost data in the dataset, so CAC and ROI can not be calculated.
SELECT
  u.traffic_source,
  COUNT(DISTINCT u.id) AS registered_users,
  COUNT(DISTINCT oi.user_id) AS buyers,
  ROUND(COUNT(DISTINCT oi.user_id) / COUNT(DISTINCT u.id) * 100, 1) AS buyer_rate_pct,
  ROUND(SUM(oi.sale_price), 2) AS net_revenue,
  ROUND(SUM(oi.sale_price) / COUNT(DISTINCT oi.user_id), 2) AS revenue_per_buyer
FROM `bigquery-public-data.thelook_ecommerce.users` AS u
LEFT JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  ON oi.user_id = u.id
  AND oi.created_at < '2026-10-01'
  AND oi.status NOT IN ('Cancelled', 'Returned')
WHERE u.created_at < '2026-10-01'
GROUP BY u.traffic_source
ORDER BY net_revenue DESC;

-- 3b. Repeat buyers by traffic source
-- Share of buyers who made 2 or more orders
-- result: repeat rate is about 30% in every channel (29.3% to 30.7%)
-- and average orders per buyer is 1.39 to 1.42. The differences are too small to matter.
-- Buyers match 3a, so the join is correct.
-- Conclusion for 3a and 3b: channels differ in volume, not in customer quality.
WITH buyer_orders AS (
  SELECT
    u.traffic_source,
    oi.user_id,
    COUNT(DISTINCT oi.order_id) AS orders_cnt
  FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
    ON u.id = oi.user_id
  WHERE oi.created_at < '2026-10-01'
    AND oi.status NOT IN ('Cancelled', 'Returned')
  GROUP BY u.traffic_source, oi.user_id
)
SELECT
  traffic_source,
  COUNT(*) AS buyers,
  COUNTIF(orders_cnt >= 2) AS repeat_buyers,
  ROUND(COUNTIF(orders_cnt >= 2) / COUNT(*) * 100, 1) AS repeat_rate_pct,
  ROUND(AVG(orders_cnt), 2) AS avg_orders_per_buyer
FROM buyer_orders
GROUP BY traffic_source
ORDER BY buyers DESC;
