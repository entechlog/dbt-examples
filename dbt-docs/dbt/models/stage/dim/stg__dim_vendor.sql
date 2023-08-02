{{ config(
  alias='dim_vendor',
  materialized='view',
  tags=['stage', 'dim']
) }}

WITH source AS (
  SELECT DISTINCT
    vendor_code::VARCHAR(128) AS vendor_code,
    vendor_name::VARCHAR(128) AS vendor_name
  FROM {{ ref('ref__vendor') }}
),

union_with_defaults AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['vendor_code']) }}::VARCHAR(128) AS vendor_id,
    vendor_code,
    vendor_name
  FROM source

  UNION

  SELECT '0'::VARCHAR(128) AS vendor_id,
    'Unknown'::VARCHAR(128) AS vendor_code,
    'Unknown'::VARCHAR(128) AS vendor_name

  UNION

  SELECT '1'::VARCHAR(128) AS vendor_id,
    'Not Applicable'::VARCHAR(128) AS vendor_code,
    'Not Applicable'::VARCHAR(128) AS vendor_name

  UNION

  SELECT '2'::VARCHAR(128) AS vendor_id,
    'All'::VARCHAR(128) AS vendor_code,
    'All'::VARCHAR(128) AS vendor_name
),

deduplicated AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY vendor_code, vendor_name ORDER BY vendor_id, vendor_code, vendor_name) AS row_num
  FROM union_with_defaults
)

SELECT vendor_id, vendor_code, vendor_name
FROM deduplicated
WHERE row_num = 1
