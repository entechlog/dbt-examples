{{ config(
  alias='dim_rate',
  materialized='view',
  tags=['stage', 'dim']
) }}

WITH source AS (
  SELECT DISTINCT
    rate_code::VARCHAR(128) AS rate_code,
    rate_name::VARCHAR(128) AS rate_name
  FROM {{ ref('ref__rate') }}
),

union_with_defaults AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['rate_code']) }}::VARCHAR(128) AS rate_id,
    rate_code,
    rate_name
  FROM source

  UNION

  SELECT '0'::VARCHAR(128) AS rate_id,
    'Unknown'::VARCHAR(128) AS rate_code,
    'Unknown'::VARCHAR(128) AS rate_name

  UNION

  SELECT '1'::VARCHAR(128) AS rate_id,
    'Not Applicable'::VARCHAR(128) AS rate_code,
    'Not Applicable'::VARCHAR(128) AS rate_name

  UNION

  SELECT '2'::VARCHAR(128) AS rate_id,
    'All'::VARCHAR(128) AS rate_code,
    'All'::VARCHAR(128) AS rate_name
),

deduplicated AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY rate_code, rate_name ORDER BY rate_id, rate_code, rate_name) AS row_num
  FROM union_with_defaults
)

SELECT rate_id, rate_code, rate_name
FROM deduplicated
WHERE row_num = 1