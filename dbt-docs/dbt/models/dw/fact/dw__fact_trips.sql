{{ config(alias="trips", materialized="table", transient=false, tags=["dw", "fact"]) }}

select
    coalesce(dv.vendor_id, '0') as vendor_id,
    coalesce(dd_pickup.date_id, '0') as pickup_date_id,
    coalesce(dd_dropoff.date_id, '0') as dropoff_date_id,
    coalesce(dl_pickup.location_id, '0') as pickup_location_id,
    coalesce(dl_dropoff.location_id, '0') as dropoff_location_id,
    coalesce(dr.rate_id, '0') as rate_id,
    coalesce(dp.payment_type_id, '0') as payment_type_id,
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
from {{ ref("stg__fact_trips") }} as ft
left join {{ ref("dw__dim_vendor") }} as dv on ft.vendor_code = dv.vendor_code
left join
    {{ ref("dw__dim_date") }} as dd_pickup on date(ft.pickup_timestamp) = dd_pickup.date
left join
    {{ ref("dw__dim_date") }} as dd_dropoff
    on date(ft.dropoff_timestamp) = dd_dropoff.date
left join
    {{ ref("dw__dim_location") }} as dl_pickup
    on ft.pickup_latitude = dl_pickup.latitude
    and ft.pickup_longitude = dl_pickup.longitude
left join
    {{ ref("dw__dim_location") }} as dl_dropoff
    on ft.dropoff_latitude = dl_dropoff.latitude
    and ft.dropoff_longitude = dl_dropoff.longitude
left join {{ ref("dw__dim_rate") }} as dr on ft.rate_code = dr.rate_code
left join
    {{ ref("dw__dim_payment_type") }} as dp
    on ft.payment_type_code = dp.payment_type_code
