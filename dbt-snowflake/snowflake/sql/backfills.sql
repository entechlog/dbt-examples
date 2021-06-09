UPDATE DBT_DEMO_STAGING.SAKILA.stg_customer
SET CUSTOMER_DISTRICT = 'Kansas', LAST_UPDATE = current_timestamp(2)
WHERE CUSTOMER_ID = 1;
		
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

ALTER TABLE "DBT_DEMO_MARTS"."CORE"."DIM_CUSTOMER_INSERT_BY_PERIOD"
ADD COLUMN CUSTOMER_DISTRICT VARCHAR DEFAULT NULL;

{{
  config(
    materialized = "vault_insert_by_period",
    period = "year",
    timestamp_field = "last_update",
    start_date = "2021-01-01",
    stop_date = "2021-04-01", 
  )
}}

WITH stage
AS (
	SELECT CUSTOMER_ID,
		CUSTOMER_FIRST_NAME,
		CUSTOMER_LAST_NAME,
		CUSTOMER_EMAIL,
		CUSTOMER_DISTRICT,
		LAST_UPDATE
	FROM {{ ref('stg_customer') }}
	WHERE __PERIOD_FILTER__
	)

SELECT *
FROM stage
