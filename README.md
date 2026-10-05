# E-commerce Customer Acquisition & Retention Analysis

SQL analysis of an online clothing store: revenue trends, acquisition channels,
customer retention and product returns.

## Business context
Management wants to know which acquisition channels are worth investing in
and why customers do not come back.

## Dataset
`bigquery-public-data.thelook_ecommerce` (synthetic e-commerce data in BigQuery):
about 80K customers, 125K orders, 181K order items, 2019 to 2026.

## Reproducibility
The public dataset is regenerated from time to time, so numbers can change between runs
(for example, 2019 net revenue changed by about 5% between two runs).
The queries were run on different days, so numbers in different files can differ
by 1-2%. The exported CSV files and screenshots in `results/` are the results
that the findings below are based on. The conclusions do not change between runs.

## Definitions
- **Net revenue**: sum of `sale_price` for order items that are not Cancelled or Returned.
- **Data cutoff**: only rows with `created_at < 2026-10-01` are used,
  so results are reproducible.
- **Repeat buyer**: a customer with 2 or more non-cancelled, non-returned orders.
- **Repeat within N days**: second order made within N days of the first one.
  Only customers with at least N days of data after their first order are compared,
  otherwise recent customers look like they never came back.
- **Gross margin**: (`sale_price` minus product `cost`) divided by `sale_price`,
  for items that are not Cancelled or Returned.
- **Return rate**: Returned items divided by all items that were not Cancelled.

## Business questions
1. How did revenue, orders and average order value change over time?
2. Which acquisition channels bring the most valuable customers?
3. How many customers make a second purchase, and does it change by cohort?
4. Which product categories bring the most revenue and have the most returns?

## Key findings so far
- Net revenue grew from about $65K in 2019 to about $1.87M in 2025 (full years).
  January to September 2026 already reached about $2.5M.
- A fair like-for-like comparison (January to September of each year) shows about +89%
  for 2026. The plain yearly comparison showed only +34% because 2026 is incomplete.
- Growth comes from the number of orders. Average order value stayed between $83 and $87.
- Search brings about 70% of users and about 70% of net revenue.
- Channels do not differ in customer quality: buyer rate 64.6% to 66.2%,
  revenue per buyer $118 to $122, repeat rate 29.3% to 30.7%.
  They differ only in volume.
- Newer cohorts come back more often: the share of customers with a second order
  within 365 days grew from 9.7% (2019 cohort) to 22.6% (2025 cohort).
- Repeat purchases are spread over a long time: 14.1% of customers come back within
  365 days and 25.3% within 730 days, so no window shows the full picture.
- About half of the January to September 2026 revenue growth comes from repeat orders
  (+133% orders) and about half from new customers (+69%).
- Revenue is concentrated: the top 3 categories give 31.7% of net revenue
  and the top 10 give 68.4%. Overall gross margin is about 51.9%.
- The biggest categories by revenue are not always the most profitable.
  Outerwear & Coats is first by revenue and by gross profit (margin 55.6%),
  Jeans is second by revenue but has a margin of 46.4%, below average.
  Highest margins are in smaller categories (Blazers & Jackets 62.1%,
  Suits & Sport Coats 59.9%, Accessories 59.9%).
- The overall return rate is 11.9% (about $1.06M of revenue). It is almost the same
  in all categories (mostly 11.4% to 12.7%) and in all channels (11.4% to 13.3%).
  Big categories lose more returned revenue only because they are big.
- Display is slightly the weakest channel on buyer rate, revenue per buyer,
  repeat rate and return rate, but all differences are within random noise.
- Recommendation: calculate customer acquisition cost per channel and test
  a budget increase in one smaller channel before moving money from Search.
  Rank product categories by gross profit, not only by revenue.

## Data quality notes and limitations
- The dataset is synthetic and is regenerated between runs, so exact numbers can differ slightly.
- 1,582 order items have dates in the future (October 4 to 8, 2026) and are excluded by the cutoff.
- Order statuses do not change over time like in a real shop: even 2019 orders
  are about 47% Processing or Shipped.
- Growth of first-time customers jumps from about 32% to 69% in 2026. I checked order
  statuses as a possible reason and found no difference, so this is treated as a feature
  of the data and I do not draw conclusions from the growth rate.
- Category names overlap (Suits and Suits & Sport Coats, Socks and Socks & Hosiery,
  Pants and Pants & Capris) and their margins differ a lot, so I kept them as they are.
- There is no marketing cost data, so CAC and ROI cannot be calculated.

## Repository structure
- `sql/` queries, numbered in the order of analysis
- `results/csv/` exported aggregated results
- `results/img/` screenshots

## Tools
BigQuery (SQL), Tableau Public or Looker Studio (dashboard)
