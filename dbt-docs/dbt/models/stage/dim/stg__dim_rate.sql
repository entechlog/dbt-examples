{{ config(alias="dim_rate", materialized="view", tags=["stage", "dim"]) }}

with
    source as (
        select distinct
            rate_code::varchar(128) as rate_code, rate_name::varchar(128) as rate_name
        from {{ ref("ref__rate") }}
    ),

    union_with_defaults as (
        select
            {{ dbt_utils.generate_surrogate_key(["rate_code"]) }}::varchar(
                128
            ) as rate_id,
            rate_code,
            rate_name
        from source

        union

        select
            '0'::varchar(128) as rate_id,
            'Unknown'::varchar(128) as rate_code,
            'Unknown'::varchar(128) as rate_name

        union

        select
            '1'::varchar(128) as rate_id,
            'Not Applicable'::varchar(128) as rate_code,
            'Not Applicable'::varchar(128) as rate_name

        union

        select
            '2'::varchar(128) as rate_id,
            'All'::varchar(128) as rate_code,
            'All'::varchar(128) as rate_name
    ),

    deduplicated as (
        select
            *,
            row_number() over (
                partition by rate_code, rate_name order by rate_id, rate_code, rate_name
            ) as row_num
        from union_with_defaults
    )

select rate_id, rate_code, rate_name
from deduplicated
where row_num = 1
