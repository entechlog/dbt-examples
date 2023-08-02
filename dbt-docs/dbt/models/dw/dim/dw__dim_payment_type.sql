{{ config(
  alias='payment_type',
  materialized='table',
  transient=false,
  tags=['dw', 'dim']
) }}

SELECT
  payment_type_id,
  payment_type_code,
  payment_type_name
FROM {{ ref('stg__dim_payment_type') }}
