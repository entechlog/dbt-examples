{{
  config(
    materialized = "vault_insert_by_period",
    period = "year",
    timestamp_field = "last_update",
    start_date = "2006-01-01",
    stop_date = "2021-01-01", 
  )
}}

WITH stage
AS (
	SELECT CUSTOMER_ID,
		CUSTOMER_FIRST_NAME,
		CUSTOMER_LAST_NAME,
		CUSTOMER_EMAIL,
		LAST_UPDATE
	FROM {{ ref('stg_customer') }}
	WHERE __PERIOD_FILTER__
	)

SELECT *
FROM stage