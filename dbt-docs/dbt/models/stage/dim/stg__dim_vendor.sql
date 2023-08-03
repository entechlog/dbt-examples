{{ config(alias="dim_vendor", materialized="view", tags=["stage", "dim"]) }}

with
    source as (
        select distinct
            vendor_code::varchar(128) as vendor_code,
            vendor_name::varchar(128) as vendor_name
        from {{ ref("ref__vendor") }}
    ),

    union_with_defaults as (
        select
            {{ dbt_utils.generate_surrogate_key(["vendor_code"]) }}::varchar(
                128
            ) as vendor_id,
            vendor_code,
            vendor_name
        from source

        union

        select
            '0'::varchar(128) as vendor_id,
            'Unknown'::varchar(128) as vendor_code,
            'Unknown'::varchar(128) as vendor_name

        union

        select
            '1'::varchar(128) as vendor_id,
            'Not Applicable'::varchar(128) as vendor_code,
            'Not Applicable'::varchar(128) as vendor_name

        union

        select
            '2'::varchar(128) as vendor_id,
            'All'::varchar(128) as vendor_code,
            'All'::varchar(128) as vendor_name
    ),

    deduplicated as (
        select
            *,
            row_number() over (
                partition by vendor_code, vendor_name
                order by vendor_id, vendor_code, vendor_name
            ) as row_num
        from union_with_defaults
    )

select vendor_id, vendor_code, vendor_name
from deduplicated
where row_num = 1
