{{ config(
  alias='dim_payment',
  materialized='view',
  tags=['stage', 'dim']
) }}

WITH source AS (
  SELECT DISTINCT
    payment_type_code::VARCHAR(128) AS payment_type_code,
    payment_type_name::VARCHAR(128) AS payment_type_name
  FROM {{ ref('ref__payment_type') }}
),

union_with_defaults AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['payment_type_code']) }}::VARCHAR(128) AS payment_type_id,
    payment_type_code,
    payment_type_name
  FROM source

  UNION

  SELECT '0'::VARCHAR(128) AS payment_type_id,
    'Unknown'::VARCHAR(128) AS payment_type_code,
    'Unknown'::VARCHAR(128) AS payment_type_name

  UNION

  SELECT '1'::VARCHAR(128) AS payment_type_id,
    'Not Applicable'::VARCHAR(128) AS payment_type_code,
    'Not Applicable'::VARCHAR(128) AS payment_type_name

  UNION

  SELECT '2'::VARCHAR(128) AS payment_type_id,
    'All'::VARCHAR(128) AS payment_type_code,
    'All'::VARCHAR(128) AS payment_type_name
),

deduplicated AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY payment_type_code, payment_type_name ORDER BY payment_type_id, payment_type_code, payment_type_name) AS row_num
  FROM union_with_defaults
)

SELECT payment_type_id, payment_type_code, payment_type_name
FROM deduplicated
WHERE row_num = 1
