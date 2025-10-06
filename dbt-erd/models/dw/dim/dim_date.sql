{{ config(
    materialized = 'table',
    tags=["dw", "dim"]
) }}

WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('1900-01-01' as date)",
        end_date="cast('2100-12-31' as date)"
    ) }}
),

date_attributes AS (
    SELECT
        date_day,
        CAST(strftime(date_day, '%Y%m%d') AS INTEGER)      AS date_id,
        CAST(strftime(date_day, '%w') AS INTEGER)          AS day_of_week,
        strftime(date_day, '%A')                            AS day_name,
        EXTRACT(DAY FROM date_day)                          AS day_of_month,
        EXTRACT(DOY FROM date_day)                          AS day_of_year,
        EXTRACT(WEEK FROM date_day)                         AS week_of_year,
        EXTRACT(MONTH FROM date_day)                        AS month_number,
        strftime(date_day, '%B')                            AS month_name,
        EXTRACT(QUARTER FROM date_day)                      AS quarter,
        EXTRACT(YEAR FROM date_day)                         AS year,
        CASE WHEN CAST(strftime(date_day, '%w') AS INTEGER) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend,
        EXTRACT(YEAR FROM date_day)                         AS fiscal_year,
        CASE
            WHEN EXTRACT(MONTH FROM date_day) BETWEEN 1 AND 3 THEN 3
            WHEN EXTRACT(MONTH FROM date_day) BETWEEN 4 AND 6 THEN 4
            WHEN EXTRACT(MONTH FROM date_day) BETWEEN 7 AND 9 THEN 1
            ELSE 2
        END                                                  AS fiscal_quarter
    FROM date_spine
)

SELECT
    date_id,
    date_day                AS date_actual,
    day_of_week,
    TRIM(day_name)          AS day_name,
    day_of_month,
    day_of_year,
    week_of_year,
    month_number,
    TRIM(month_name)        AS month_name,
    quarter,
    year,
    is_weekend,
    FALSE                   AS is_holiday,  -- Can be enhanced with holiday logic
    fiscal_year,
    fiscal_quarter
FROM date_attributes
