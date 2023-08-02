{{ config(
  alias='location',
  materialized='table',
  transient=false,
  tags=['dw', 'dim']
) }}

SELECT
  location_id,
  latitude,
  longitude
FROM {{ ref('stg__dim_location') }}
