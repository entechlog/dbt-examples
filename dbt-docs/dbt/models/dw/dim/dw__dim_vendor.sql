{{ config(
  alias='dim_vendor',
  materialized='table',
  transient=false,
  tags=['dw', 'dim']
) }}

SELECT
  vendor_id,
  vendor_code,
  vendor_name
FROM {{ ref('stg__dim_vendor') }}
