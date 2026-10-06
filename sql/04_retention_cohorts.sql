-- 4a. Share of customers who make a second order within 90 days of the first 

-- result: 56,853 customers with a first order before 2026-07-03.
-- 18,530 (32.6%) made a second order at some point, but only 3,629 (6.4%)
-- did it within 90 days. Most repeat orders come later than 90 days.
-- Customers with a first order after 2026-07-03 are excluded because they
-- have less than 90 days of data before the cutoff and would look like
-- they did not return.
WITH orders_net AS (
  SELECT
    user_id,
    order_id,
    MIN(created_at) AS order_date
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE created_at < '2026-10-01'
    AND status NOT IN ('Cancelled', 'Returned')
  GROUP BY user_id, order_id
),
ranked AS (
  SELECT
    user_id,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_num
  FROM orders_net
),
first_second AS (
  SELECT
    user_id,
    MIN(IF(order_num = 1, order_date, NULL)) AS first_order,
    MIN(IF(order_num = 2, order_date, NULL)) AS second_order
  FROM ranked
  GROUP BY user_id
)
SELECT
  COUNT(*) AS customers,
  COUNTIF(second_order IS NOT NULL) AS repeat_customers,
  COUNTIF(TIMESTAMP_DIFF(second_order, first_order, DAY) <= 90) AS repeat_within_90d,
  ROUND(COUNTIF(TIMESTAMP_DIFF(second_order, first_order, DAY) <= 90) / COUNT(*) * 100, 1) AS repeat_90d_pct
FROM first_second
WHERE first_order < TIMESTAMP('2026-07-03');

-- 4b. Share of customers with a second order within 30, 90, 180 and 365 days
-- Only customers whose first order was before 2025-10-01, so everyone
-- has at least 365 days of data

-- result (customers with first order before 2025-10-01, n = 42,375):
-- repeat within 30 days: 1.6%, 90 days: 4.7%, 180 days: 8.6%, 365 days: 16.6%
-- The curve keeps growing almost in a straight line, so even 365 days is
-- not enough to see all repeat purchases. I use 365 days as the main window
-- because it is the longest one that is fair for most customers.
WITH orders_net AS (
  SELECT
    user_id,
    order_id,
    MIN(created_at) AS order_date
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE created_at < '2026-10-01'
    AND status NOT IN ('Cancelled', 'Returned')
  GROUP BY user_id, order_id
),
ranked AS (
  SELECT
    user_id,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_num
  FROM orders_net
),
first_second AS (
  SELECT
    user_id,
    MIN(IF(order_num = 1, order_date, NULL)) AS first_order,
    MIN(IF(order_num = 2, order_date, NULL)) AS second_order
  FROM ranked
  GROUP BY user_id
)
SELECT
  COUNT(*) AS customers,
  ROUND(COUNTIF(TIMESTAMP_DIFF(second_order, first_order, DAY) <= 30) / COUNT(*) * 100, 1) AS repeat_30d_pct,
  ROUND(COUNTIF(TIMESTAMP_DIFF(second_order, first_order, DAY) <= 90) / COUNT(*) * 100, 1) AS repeat_90d_pct,
  ROUND(COUNTIF(TIMESTAMP_DIFF(second_order, first_order, DAY) <= 180) / COUNT(*) * 100, 1) AS repeat_180d_pct,
  ROUND(COUNTIF(TIMESTAMP_DIFF(second_order, first_order, DAY) <= 365) / COUNT(*) * 100, 1) AS repeat_365d_pct
FROM first_second
WHERE first_order < TIMESTAMP('2025-10-01');

-- 4c. Repeat rate by year of first order (cohorts)
-- Windows of 180 and 365 days, only customers with first order before 2025-10-01

WITH orders_net AS (
  SELECT
    user_id,
    order_id,
    MIN(created_at) AS order_date
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE created_at < '2026-10-01'
    AND status NOT IN ('Cancelled', 'Returned')
  GROUP BY user_id, order_id
),
ranked AS (
  SELECT
    user_id,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_num
  FROM orders_net
),
first_second AS (
  SELECT
    user_id,
    MIN(IF(order_num = 1, order_date, NULL)) AS first_order,
    MIN(IF(order_num = 2, order_date, NULL)) AS second_order
  FROM ranked
  GROUP BY user_id
)
SELECT
  EXTRACT(YEAR FROM first_order) AS cohort_year,
  COUNT(*) AS customers,
  ROUND(COUNTIF(TIMESTAMP_DIFF(second_order, first_order, DAY) <= 180) / COUNT(*) * 100, 1) AS repeat_180d_pct,
  ROUND(COUNTIF(TIMESTAMP_DIFF(second_order, first_order, DAY) <= 365) / COUNT(*) * 100, 1) AS repeat_365d_pct
FROM first_second
WHERE first_order < TIMESTAMP('2025-10-01')
GROUP BY cohort_year
ORDER BY cohort_year;

-- 4c result (cohorts by year of first order, n = 42,375, matches 4b):
-- repeat within 365 days: 9.7% (2019), 11.6%, 11.3%, 13.5%, 13.8%, 18.2%, 22.6% (2025)
-- repeat within 180 days: 5.0% (2019) up to 12.1% (2025)
-- Newer cohorts come back more often than older ones, and the growth speeds up
-- in 2024 and 2025. Channel mix does not explain it (see 3a and 3b).
-- The 2025 cohort has only customers from January to September.

-- 4d. Longer window check: 365 and 730 days
-- Only customers with first order before 2024-10-01, so everyone has 2 years of data
-- (same CTEs as in 4c)
SELECT
  COUNT(*) AS customers,
  ROUND(COUNTIF(TIMESTAMP_DIFF(second_order, first_order, DAY) <= 365) / COUNT(*) * 100, 1) AS repeat_365d_pct,
  ROUND(COUNTIF(TIMESTAMP_DIFF(second_order, first_order, DAY) <= 730) / COUNT(*) * 100, 1) AS repeat_730d_pct
FROM first_second
WHERE first_order < TIMESTAMP('2024-10-01');

-- 4d result (customers with first order before 2024-10-01, n = 28,941):
-- repeat within 365 days: 14.1%, within 730 days: 25.3%
-- The cumulative share still grows after one year, but more slowly:
-- +14.1 points in the first year and +11.2 points in the second year.
-- Even after 2 years about 75% of customers have not made a second order.

-- 4e. Orders by year split into first orders and repeat orders
-- Checking if the fast growth in 2026 comes from new or returning customers
WITH orders_net AS (
  SELECT
    user_id,
    order_id,
    MIN(created_at) AS order_date,
    SUM(sale_price) AS order_revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE created_at < '2026-10-01'
    AND status NOT IN ('Cancelled', 'Returned')
  GROUP BY user_id, order_id
),
ranked AS (
  SELECT
    order_date,
    order_revenue,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_num
  FROM orders_net
)
SELECT
  EXTRACT(YEAR FROM order_date) AS year,
  COUNT(*) AS orders_cnt,
  COUNTIF(order_num = 1) AS first_orders,
  COUNTIF(order_num > 1) AS repeat_orders,
  ROUND(COUNTIF(order_num > 1) / COUNT(*) * 100, 1) AS repeat_orders_pct,
  ROUND(SUM(IF(order_num > 1, order_revenue, 0)), 2) AS repeat_revenue
FROM ranked
GROUP BY year
ORDER BY year;

-- 4e result: share of repeat orders grows every year, from 3.3% in 2019 to 38.9% in 2026.
-- Part of this is natural, because the base of past customers keeps growing.
-- Cohorts in 4c are a cleaner way to compare retention.
-- First orders by year match the cohort sizes in 4c.
-- Order counts differ a little from 2b, the dataset was probably updated between runs.

-- 4f. First vs repeat orders, January to September only
-- Order numbers are calculated on all orders first, and the month filter
-- is applied after that, so a customer's first order is always the real first one
WITH orders_net AS (
  SELECT
    user_id,
    order_id,
    MIN(created_at) AS order_date,
    SUM(sale_price) AS order_revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE created_at < '2026-10-01'
    AND status NOT IN ('Cancelled', 'Returned')
  GROUP BY user_id, order_id
),
ranked AS (
  SELECT
    order_date,
    order_revenue,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_num
  FROM orders_net
)
SELECT
  EXTRACT(YEAR FROM order_date) AS year,
  COUNTIF(order_num = 1) AS first_orders,
  COUNTIF(order_num > 1) AS repeat_orders,
  ROUND(SUM(IF(order_num = 1, order_revenue, 0)), 2) AS first_order_revenue,
  ROUND(SUM(IF(order_num > 1, order_revenue, 0)), 2) AS repeat_order_revenue
FROM ranked
WHERE EXTRACT(MONTH FROM order_date) <= 9
GROUP BY year
ORDER BY year;

-- 4f result (January to September of each year):
-- first orders: 10,427 in 2025 and 17,662 in 2026 (+69%)
-- repeat orders: 4,818 in 2025 and 11,233 in 2026 (+133%)
-- net revenue January to September: about 1.32M in 2025 and 2.48M in 2026 (+88%)
-- About 52% of the revenue growth comes from first orders and 48% from repeat orders,
-- although repeat orders were only 31% of revenue in 2025.
-- First orders grew 32% to 37% in 2024 and 2025 and 69% in 2026.
-- I can not explain this jump from the data, it is probably a feature of the generator.
