{{ config(
  alias='rate',
  materialized='table',
  transient=false,
  tags=['dw', 'dim']
) }}

SELECT
  rate_id,
  rate_code,
  rate_name
FROM {{ ref('stg__dim_rate') }}