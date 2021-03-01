{{
  config(
    materialized = "vault_insert_by_period",
    period = "day",
    timestamp_field = "last_update",
    start_date = "2021-01-01",
    stop_date = "2021-12-01", 
  )
}}

SELECT
CUSTOMER_ID,
CUSTOMER_FIRST_NAME,
CUSTOMER_LAST_NAME,
CUSTOMER_EMAIL,
LAST_UPDATE
FROM {{ ref('stg_customer') }}
where __PERIOD_FILTER__
