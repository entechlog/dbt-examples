{{ config(
  alias='dim_location',
  materialized='view',
  tags=['stage', 'dim']
) }}

WITH source AS (
  SELECT
    DISTINCT pickup_latitude::VARCHAR(128) AS pickup_latitude,
    pickup_longitude::VARCHAR(128) AS pickup_longitude,
    dropoff_latitude::VARCHAR(128) AS dropoff_latitude,
    dropoff_longitude::VARCHAR(128) AS dropoff_longitude
  FROM {{ ref('trip_data_nyc') }}
),

union_with_defaults AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['pickup_latitude', 'pickup_longitude']) }}::VARCHAR(128) AS location_id,
    pickup_latitude::VARCHAR(128) AS latitude,
    pickup_longitude::VARCHAR(128) AS longitude
  FROM source

  UNION

  SELECT
    {{ dbt_utils.generate_surrogate_key(['dropoff_latitude', 'dropoff_longitude']) }}::VARCHAR(128) AS location_id,
    dropoff_latitude::VARCHAR(128) AS latitude,
    dropoff_longitude::VARCHAR(128) AS longitude
  FROM source

  UNION

  SELECT '0'::VARCHAR(128),
    'Unknown'::VARCHAR(128),
    'Unknown'::VARCHAR(128)

  UNION

  SELECT '1'::VARCHAR(128),
    'Not Applicable'::VARCHAR(128),
    'Not Applicable'::VARCHAR(128)

  UNION

  SELECT '2'::VARCHAR(128),
    'All'::VARCHAR(128),
    'All'::VARCHAR(128)
),

deduplicated AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY location_id, latitude, longitude ORDER BY location_id, latitude, longitude) AS row_num
  FROM union_with_defaults
)

SELECT location_id, latitude, longitude
FROM deduplicated
WHERE row_num = 1