-- 00_create_snapshot.sql
-- The public dataset is regenerated from time to time, so numbers can change between runs.
-- I copy the tables once into my own dataset and run the analysis on the copy.

CREATE SCHEMA IF NOT EXISTS thelook_snapshot;

CREATE OR REPLACE TABLE thelook_snapshot.order_items AS
SELECT * FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE created_at < '2026-10-01';

CREATE OR REPLACE TABLE thelook_snapshot.orders AS
SELECT * FROM `bigquery-public-data.thelook_ecommerce.orders`
WHERE created_at < '2026-10-01';

CREATE OR REPLACE TABLE thelook_snapshot.users AS
SELECT * FROM `bigquery-public-data.thelook_ecommerce.users`
WHERE created_at < '2026-10-01';

CREATE OR REPLACE TABLE thelook_snapshot.products AS
SELECT * FROM `bigquery-public-data.thelook_ecommerce.products`;
