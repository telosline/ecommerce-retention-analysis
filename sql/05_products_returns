-- 05_products_returns.sql
-- Net revenue = all order items except Cancelled and Returned
-- Data cutoff: created_at < '2026-10-01'

-- 5a. Net revenue and gross margin by product category
-- Margin = sale_price minus product cost, cost is in the products table
SELECT
  p.category,
  COUNT(*) AS items_sold,
  ROUND(SUM(oi.sale_price), 2) AS net_revenue,
  ROUND(SUM(oi.sale_price) / SUM(SUM(oi.sale_price)) OVER () * 100, 1) AS revenue_share_pct,
  ROUND(SUM(oi.sale_price - p.cost), 2) AS gross_profit,
  ROUND(SUM(oi.sale_price - p.cost) / SUM(oi.sale_price) * 100, 1) AS gross_margin_pct
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
  ON p.id = oi.product_id
WHERE oi.created_at < '2026-10-01'
  AND oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY p.category
ORDER BY net_revenue DESC;

-- 5a result: 26 categories, net revenue 7.84M, gross profit about 4.07M,
-- overall gross margin about 51.9%.
-- Top 3 categories by revenue give 31.7% of revenue, top 10 give 68.4%.
-- Outerwear & Coats is first by revenue (12.4%) and by gross profit (540.9K), margin 55.6%.
-- Jeans is second by revenue, but its margin is 46.4%, below average.
-- Highest margins are in smaller categories: Blazers & Jackets 62.1%, Skirts 60.1%,
-- Suits & Sport Coats 59.9%, Accessories 59.9%.
-- Lowest margins: Clothing Sets 37.9%, Suits 39.6%, Socks 39.7%, Leggings 40.1%.
-- The biggest categories by revenue are not always the most profitable.
-- Category names overlap (Suits and Suits & Sport Coats, Socks and Socks & Hosiery,
-- Pants and Pants & Capris) and margins differ a lot between them.
-- I keep the categories as they are in the data.

-- 5b. Return rate and returned revenue by category
-- Return rate = Returned items / all items that were not cancelled
SELECT
  p.category,
  COUNTIF(oi.status != 'Cancelled') AS items_not_cancelled,
  COUNTIF(oi.status = 'Returned') AS returned_items,
  ROUND(COUNTIF(oi.status = 'Returned') / COUNTIF(oi.status != 'Cancelled') * 100, 1) AS return_rate_pct,
  ROUND(SUM(IF(oi.status = 'Returned', oi.sale_price, 0)), 2) AS returned_revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
  ON p.id = oi.product_id
WHERE oi.created_at < '2026-10-01'
GROUP BY p.category
ORDER BY returned_revenue DESC;

-- 5b result: 17,697 returned items out of 148,791 items that were not cancelled,
-- overall return rate 11.9%, returned revenue about 1.06M.
-- Return rate is almost the same in all categories, mostly 11.4% to 12.7%.
-- High margin categories do not return more than average:
-- Blazers & Jackets 11.5%, Suits & Sport Coats 12.1%.
-- Suits (13.3%) and Clothing Sets (6.7%) are the only categories far from average,
-- but they have few items, so I do not draw conclusions from them.
-- Returned revenue follows total revenue, big categories lose more only because they are big.
-- Returns are a store-wide level, not a problem of specific categories.

-- 5c. Return rate by traffic source
-- Checking if some channels bring customers who return items more often
SELECT
  u.traffic_source,
  COUNTIF(oi.status != 'Cancelled') AS items_not_cancelled,
  COUNTIF(oi.status = 'Returned') AS returned_items,
  ROUND(COUNTIF(oi.status = 'Returned') / COUNTIF(oi.status != 'Cancelled') * 100, 1) AS return_rate_pct
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
  ON u.id = oi.user_id
WHERE oi.created_at < '2026-10-01'
GROUP BY u.traffic_source
ORDER BY items_not_cancelled DESC;

-- 5c result: return rate by channel is 11.4% to 13.3%, overall 11.9%.
-- Items match 5b (148,791 not cancelled, 17,697 returned).
-- Display is the highest (13.3%), but the difference is about 1.5 points and
-- the random error with this sample size is about 1.3 points, so it is within noise.
-- Display is also slightly the lowest in buyer rate, revenue per buyer and repeat rate (3a, 3b).
-- All differences are small, so I do not call Display a bad channel.
-- Returns do not depend on channel, same as customer quality.
