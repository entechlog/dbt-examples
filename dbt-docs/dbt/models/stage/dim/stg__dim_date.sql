{{ config(
  alias='dim_date',
  materialized='view',
  tags=['stage', 'dim']
) }}

WITH source AS (
  SELECT
    date::DATE AS date,
    EXTRACT(YEAR FROM date) AS year,
    EXTRACT(MONTH FROM date) AS month,
    EXTRACT(DAY FROM date) AS day,
    UPPER(DAYNAME(date)) AS day_name,
    UPPER(MONTHNAME(date)) AS month_name,
    DAYOFWEEKISO(date) AS day_of_week,
    DAYOFYEAR(date) AS day_of_year,
    CASE WHEN UPPER(DAYNAME(date)) IN ('SAT', 'SUN') THEN TRUE ELSE FALSE END AS is_weekend,
    NULL AS is_holiday
  FROM (
    SELECT
      DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '1900-01-01') AS date
    FROM TABLE(GENERATOR(ROWCOUNT => 219511)) -- Generate dates from 1900 to 2500
  )
),

union_with_defaults AS (
  SELECT
    TO_CHAR(date, 'YYYYMMDD') AS date_id,
    date::DATE AS date,
    year::VARCHAR(128) AS year,
    month::VARCHAR(128) AS month,
    day::VARCHAR(128) AS day,
    day_name::VARCHAR(128) AS day_name,
    month_name::VARCHAR(128) AS month_name,
    day_of_week::VARCHAR(128) AS day_of_week,
    day_of_year::VARCHAR(128) AS day_of_year,
    is_weekend::VARCHAR(128) AS is_weekend,
    is_holiday::VARCHAR(128) AS is_holiday
  FROM source

  UNION

  SELECT '0'::VARCHAR(128) AS date_id,
    NULL::DATE AS date,
    'Unknown'::VARCHAR(128) AS year,
    'Unknown'::VARCHAR(128) AS month,
    'Unknown'::VARCHAR(128) AS day,
    'Unknown'::VARCHAR(128) AS day_name,
    'Unknown'::VARCHAR(128) AS month_name,
    'Unknown'::VARCHAR(128) AS day_of_week,
    'Unknown'::VARCHAR(128) AS day_of_year,
    'Unknown'::VARCHAR(128) AS is_weekend,
    'Unknown'::VARCHAR(128) AS is_holiday

  UNION

  SELECT '1'::VARCHAR(128) AS date_id,
    NULL::DATE AS date,
    'Not Applicable'::VARCHAR(128) AS year,
    'Not Applicable'::VARCHAR(128) AS month,
    'Not Applicable'::VARCHAR(128) AS day,
    'Not Applicable'::VARCHAR(128) AS day_name,
    'Not Applicable'::VARCHAR(128) AS month_name,
    'Not Applicable'::VARCHAR(128) AS day_of_week,
    'Not Applicable'::VARCHAR(128) AS day_of_year,
    'Not Applicable'::VARCHAR(128) AS is_weekend,
    'Not Applicable'::VARCHAR(128) AS is_holiday

  UNION

  SELECT '2'::VARCHAR(128) AS date_id,
    NULL::DATE AS date,
    'All'::VARCHAR(128) AS year,
    'All'::VARCHAR(128) AS month,
    'All'::VARCHAR(128) AS day,
    'All'::VARCHAR(128) AS day_name,
    'All'::VARCHAR(128) AS month_name,
    'All'::VARCHAR(128) AS day_of_week,
    'All'::VARCHAR(128) AS day_of_year,
    'All'::VARCHAR(128) AS is_weekend,
    'All'::VARCHAR(128) AS is_holiday
),

deduplicated AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY date, year, month, day, day_name, month_name, day_of_week, day_of_year, is_weekend, is_holiday ORDER BY date_id, date, year, month, day, day_name, month_name, day_of_week, day_of_year, is_weekend, is_holiday) AS row_num
  FROM union_with_defaults
)

SELECT date_id, date, year, month, day, day_name, month_name, day_of_week, day_of_year, is_weekend, is_holiday
FROM deduplicated
WHERE row_num = 1
