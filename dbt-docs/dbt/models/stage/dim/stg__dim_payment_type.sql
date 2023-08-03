{{ config(alias="dim_payment", materialized="view", tags=["stage", "dim"]) }}

with
    source as (
        select distinct
            payment_type_code::varchar(128) as payment_type_code,
            payment_type_name::varchar(128) as payment_type_name
        from {{ ref("ref__payment_type") }}
    ),

    union_with_defaults as (
        select
            {{ dbt_utils.generate_surrogate_key(["payment_type_code"]) }}::varchar(
                128
            ) as payment_type_id,
            payment_type_code,
            payment_type_name
        from source

        union

        select
            '0'::varchar(128) as payment_type_id,
            'Unknown'::varchar(128) as payment_type_code,
            'Unknown'::varchar(128) as payment_type_name

        union

        select
            '1'::varchar(128) as payment_type_id,
            'Not Applicable'::varchar(128) as payment_type_code,
            'Not Applicable'::varchar(128) as payment_type_name

        union

        select
            '2'::varchar(128) as payment_type_id,
            'All'::varchar(128) as payment_type_code,
            'All'::varchar(128) as payment_type_name
    ),

    deduplicated as (
        select
            *,
            row_number() over (
                partition by payment_type_code, payment_type_name
                order by payment_type_id, payment_type_code, payment_type_name
            ) as row_num
        from union_with_defaults
    )

select payment_type_id, payment_type_code, payment_type_name
from deduplicated
where row_num = 1
