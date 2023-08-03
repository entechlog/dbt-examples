-- stg__fact_trips.sql
{{ config(alias="trips", materialized="view", tags=["stage", "fact"]) }}

with
    source as (
        select
            vendorid::varchar(128) as vendor_code,
            tpep_pickup_datetime::timestamp as pickup_timestamp,
            tpep_dropoff_datetime::timestamp as dropoff_timestamp,
            passenger_count::int as passenger_count,
            trip_distance::float as trip_distance,
            pickup_longitude::varchar(128) as pickup_longitude,
            pickup_latitude::varchar(128) as pickup_latitude,
            dropoff_longitude::varchar(128) as dropoff_longitude,
            dropoff_latitude::varchar(128) as dropoff_latitude,
            ratecodeid::varchar(128) as rate_code,
            store_and_fwd_flag::varchar(128) as store_and_fwd_flag,
            payment_type::varchar(128) as payment_type_code,
            fare_amount::float as fare_amount,
            extra::float as extra,
            mta_tax::float as mta_tax,
            tip_amount::float as tip_amount,
            tolls_amount::float as tolls_amount,
            improvement_surcharge::float as improvement_surcharge,
            total_amount::float as total_amount
        from {{ ref("trip_data_nyc") }}
    ),

    deduplicated as (
        select
            *,
            row_number() over (
                partition by
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
                order by vendor_code, pickup_timestamp, dropoff_timestamp
            ) as row_num
        from source
    )

select
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
from deduplicated
where row_num = 1
