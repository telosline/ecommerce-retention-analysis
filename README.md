# E-commerce Customer Acquisition & Retention Analysis

SQL analysis of an online clothing store: revenue trends, acquisition channels,
customer retention and product returns.

## Business context
Management wants to know which acquisition channels are worth investing in
and why customers do not come back.

## Dataset
`bigquery-public-data.thelook_ecommerce` (synthetic e-commerce data in BigQuery):
about 80K customers, 125K orders, 181K order items, 2019 to 2026.

## Definitions
- **Net revenue**: sum of `sale_price` for order items that are not Cancelled or Returned.
- **Data cutoff**: only rows with `created_at < 2026-10-01` are used,
  so results are reproducible.
- **Repeat buyer**: a customer with 2 or more non-cancelled, non-returned orders.

## Business questions
1. How did revenue, orders and average order value change over time?
2. Which acquisition channels bring the most valuable customers?
3. How many customers make a second purchase (cohort analysis)? (TODO)
4. Which product categories bring the most revenue and have the most returns? (TODO)

## Key findings so far
- Net revenue grew from $38.7K in 2019 to $2.5M in January to September 2026.
- A fair like-for-like comparison (January to September of each year) shows +89.0%
  for 2026. The plain yearly comparison showed only +33.9% because 2026 is incomplete.
- Growth comes from the number of orders. Average order value stayed between $83 and $87.
- Search brings about 70% of users and about 70% of net revenue.
- Channels do not differ in customer quality: buyer rate 64.6% to 66.2%,
  revenue per buyer $118 to $122, repeat rate 29.3% to 30.7%.
  They differ only in volume.
- Recommendation: calculate customer acquisition cost per channel and test
  a budget increase in one smaller channel before moving money from Search.

## Data quality notes and limitations
- The dataset is synthetic.
- 1,582 order items have dates in the future (October 4 to 8, 2026) and are excluded by the cutoff.
- Order statuses do not change over time like in a real shop: even 2019 orders
  are about 47% Processing or Shipped.
- Growth in 2026 jumps from about 45% to 89%. I checked order statuses as a possible
  reason and found no difference, so this is treated as a feature of the data.
- There is no marketing cost data, so CAC and ROI cannot be calculated.

## Repository structure
- `sql/` queries, numbered in the order of analysis
- `results/csv/` exported aggregated results
- `results/img/` screenshots

## Tools
BigQuery (SQL), Tableau Public or Looker Studio (dashboard)
