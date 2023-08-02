-- stg__fact_trips.sql
{{ config(
  alias='trips',
  materialized='view',
  tags=['stage', 'fact']
) }}

WITH source AS (
  SELECT
    VendorID::VARCHAR(128) AS vendor_code,
    tpep_pickup_datetime::TIMESTAMP AS pickup_timestamp,
    tpep_dropoff_datetime::TIMESTAMP AS dropoff_timestamp,
    passenger_count::INT AS passenger_count,
    trip_distance::FLOAT AS trip_distance,
    pickup_longitude::VARCHAR(128) AS pickup_longitude,
    pickup_latitude::VARCHAR(128) AS pickup_latitude,
    dropoff_longitude::VARCHAR(128) AS dropoff_longitude,
    dropoff_latitude::VARCHAR(128) AS dropoff_latitude,
    RateCodeID::VARCHAR(128) AS rate_code,
    store_and_fwd_flag::VARCHAR(128) AS store_and_fwd_flag,
    payment_type::VARCHAR(128) AS payment_type_code,
    fare_amount::FLOAT AS fare_amount,
    extra::FLOAT AS extra,
    mta_tax::FLOAT AS mta_tax,
    tip_amount::FLOAT AS tip_amount,
    tolls_amount::FLOAT AS tolls_amount,
    improvement_surcharge::FLOAT AS improvement_surcharge,
    total_amount::FLOAT AS total_amount
  FROM {{ ref('trip_data_nyc') }}
),

deduplicated AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY vendor_code, pickup_timestamp, dropoff_timestamp, passenger_count, trip_distance, pickup_longitude, pickup_latitude, dropoff_longitude, dropoff_latitude, rate_code, store_and_fwd_flag, payment_type_code, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge, total_amount ORDER BY vendor_code, pickup_timestamp, dropoff_timestamp) AS row_num
  FROM source
)

SELECT
  vendor_code,
  pickup_timestamp,
  dropoff_timestamp,
  passenger_count,
  trip_distance,
  pickup_longitude,
  pickup_latitude,
  dropoff_longitude,
  dropoff_latitude,
  rate_code,
  store_and_fwd_flag,
  payment_type_code,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  improvement_surcharge,
  total_amount
FROM deduplicated
WHERE row_num = 1
