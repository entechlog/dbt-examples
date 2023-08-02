{{ config(
  alias='trips',
  materialized='table',
  transient=false,
  tags=['dw', 'fact']
) }}

SELECT
  COALESCE(dv.vendor_id, '0') AS vendor_id,
  COALESCE(dd_pickup.date_id, '0') AS pickup_date_id,
  COALESCE(dd_dropoff.date_id, '0') AS dropoff_date_id,
  COALESCE(dl_pickup.location_id, '0') AS pickup_location_id,
  COALESCE(dl_dropoff.location_id, '0') AS dropoff_location_id,
  COALESCE(dr.rate_id, '0') AS rate_id,
  COALESCE(dp.payment_type_id, '0') AS payment_type_id,
  ft.pickup_timestamp,
  ft.dropoff_timestamp,
  ft.passenger_count,
  ft.trip_distance,
  ft.fare_amount,
  ft.extra,
  ft.mta_tax,
  ft.tip_amount,
  ft.tolls_amount,
  ft.improvement_surcharge,
  ft.total_amount
FROM {{ ref('stg__fact_trips') }} AS ft
LEFT JOIN {{ ref('dw__dim_vendor') }} AS dv ON ft.vendor_code = dv.vendor_code
LEFT JOIN {{ ref('dw__dim_date') }} AS dd_pickup ON DATE(ft.pickup_timestamp) = dd_pickup.date
LEFT JOIN {{ ref('dw__dim_date') }} AS dd_dropoff ON DATE(ft.dropoff_timestamp) = dd_dropoff.date
LEFT JOIN {{ ref('dw__dim_location') }} AS dl_pickup ON ft.pickup_latitude = dl_pickup.latitude AND ft.pickup_longitude = dl_pickup.longitude
LEFT JOIN {{ ref('dw__dim_location') }} AS dl_dropoff ON ft.dropoff_latitude = dl_dropoff.latitude AND ft.dropoff_longitude = dl_dropoff.longitude
LEFT JOIN {{ ref('dw__dim_rate') }} AS dr ON ft.rate_code = dr.rate_code
LEFT JOIN {{ ref('dw__dim_payment_type') }} AS dp ON ft.payment_type_code = dp.payment_type_code