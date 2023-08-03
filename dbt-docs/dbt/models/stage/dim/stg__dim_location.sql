{{ config(alias="dim_location", materialized="view", tags=["stage", "dim"]) }}

with
    source as (
        select distinct
            pickup_latitude::varchar(128) as pickup_latitude,
            pickup_longitude::varchar(128) as pickup_longitude,
            dropoff_latitude::varchar(128) as dropoff_latitude,
            dropoff_longitude::varchar(128) as dropoff_longitude
        from {{ ref("trip_data_nyc") }}
    ),

    union_with_defaults as (
        select
            {{
                dbt_utils.generate_surrogate_key(
                    ["pickup_latitude", "pickup_longitude"]
                )
            }}::varchar(128) as location_id,
            pickup_latitude::varchar(128) as latitude,
            pickup_longitude::varchar(128) as longitude
        from source

        union

        select
            {{
                dbt_utils.generate_surrogate_key(
                    ["dropoff_latitude", "dropoff_longitude"]
                )
            }}::varchar(128) as location_id,
            dropoff_latitude::varchar(128) as latitude,
            dropoff_longitude::varchar(128) as longitude
        from source

        union

        select '0'::varchar(128), 'Unknown'::varchar(128), 'Unknown'::varchar(128)

        union

        select
            '1'::varchar(128),
            'Not Applicable'::varchar(128),
            'Not Applicable'::varchar(128)

        union

        select '2'::varchar(128), 'All'::varchar(128), 'All'::varchar(128)
    ),

    deduplicated as (
        select
            *,
            row_number() over (
                partition by location_id, latitude, longitude
                order by location_id, latitude, longitude
            ) as row_num
        from union_with_defaults
    )

select location_id, latitude, longitude
from deduplicated
where row_num = 1
