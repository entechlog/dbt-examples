{{ config(alias="dim_date", materialized="view", tags=["stage", "dim"]) }}

with
    source as (
        select
            date::date as date,
            extract(year from date) as year,
            extract(month from date) as month,
            extract(day from date) as day,
            upper(dayname(date)) as day_name,
            upper(monthname(date)) as month_name,
            dayofweekiso(date) as day_of_week,
            dayofyear(date) as day_of_year,
            case
                when upper(dayname(date)) in ('SAT', 'SUN') then true else false
            end as is_weekend,
            null as is_holiday
        from
            (
                select
                    dateadd(
                        day, row_number() over (order by null) - 1, '1900-01-01'
                    ) as date
                from table(generator(rowcount => 219511))  -- Generate dates from 1900 to 2500
            )
    ),

    union_with_defaults as (
        select
            to_char(date, 'YYYYMMDD') as date_id,
            date::date as date,
            year::varchar(128) as year,
            month::varchar(128) as month,
            day::varchar(128) as day,
            day_name::varchar(128) as day_name,
            month_name::varchar(128) as month_name,
            day_of_week::varchar(128) as day_of_week,
            day_of_year::varchar(128) as day_of_year,
            is_weekend::varchar(128) as is_weekend,
            is_holiday::varchar(128) as is_holiday
        from source

        union

        select
            '0'::varchar(128) as date_id,
            null::date as date,
            'Unknown'::varchar(128) as year,
            'Unknown'::varchar(128) as month,
            'Unknown'::varchar(128) as day,
            'Unknown'::varchar(128) as day_name,
            'Unknown'::varchar(128) as month_name,
            'Unknown'::varchar(128) as day_of_week,
            'Unknown'::varchar(128) as day_of_year,
            'Unknown'::varchar(128) as is_weekend,
            'Unknown'::varchar(128) as is_holiday

        union

        select
            '1'::varchar(128) as date_id,
            null::date as date,
            'Not Applicable'::varchar(128) as year,
            'Not Applicable'::varchar(128) as month,
            'Not Applicable'::varchar(128) as day,
            'Not Applicable'::varchar(128) as day_name,
            'Not Applicable'::varchar(128) as month_name,
            'Not Applicable'::varchar(128) as day_of_week,
            'Not Applicable'::varchar(128) as day_of_year,
            'Not Applicable'::varchar(128) as is_weekend,
            'Not Applicable'::varchar(128) as is_holiday

        union

        select
            '2'::varchar(128) as date_id,
            null::date as date,
            'All'::varchar(128) as year,
            'All'::varchar(128) as month,
            'All'::varchar(128) as day,
            'All'::varchar(128) as day_name,
            'All'::varchar(128) as month_name,
            'All'::varchar(128) as day_of_week,
            'All'::varchar(128) as day_of_year,
            'All'::varchar(128) as is_weekend,
            'All'::varchar(128) as is_holiday
    ),

    deduplicated as (
        select
            *,
            row_number() over (
                partition by
                    date,
                    year,
                    month,
                    day,
                    day_name,
                    month_name,
                    day_of_week,
                    day_of_year,
                    is_weekend,
                    is_holiday
                order by
                    date_id,
                    date,
                    year,
                    month,
                    day,
                    day_name,
                    month_name,
                    day_of_week,
                    day_of_year,
                    is_weekend,
                    is_holiday
            ) as row_num
        from union_with_defaults
    )

select
    date_id,
    date,
    year,
    month,
    day,
    day_name,
    month_name,
    day_of_week,
    day_of_year,
    is_weekend,
    is_holiday
from deduplicated
where row_num = 1
