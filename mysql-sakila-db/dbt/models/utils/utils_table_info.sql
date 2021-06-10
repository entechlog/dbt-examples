{{ 
    config(
      alias = 'table_info',
      materialized='incremental_custom',
      incremental_strategy='merge',
      unique_key='record_id',
      should_full_refresh=False,
      on_schema_change='sync',
      pre_hook=[delete_data("DATE_ID", "20210430"),delete_data("DATE_ID", "20210501")]
  )
}}
 
WITH current_day_record
AS (
    SELECT 
        replace(DATE ({{ dbt_utils.dateadd(datepart='day', interval=11, from_date_or_timestamp=dbt_utils.current_timestamp()) }}), '-', '') AS date_id,
        table_schema,
        table_name,
        row_count AS total_row_count,
        bytes AS total_bytes
    FROM {{ source('INFORMATION_SCHEMA', 'TABLES') }}
    ORDER BY table_name ASC
    )
 
SELECT {{ dbt_utils.surrogate_key(['date_id','table_schema','table_name']) }} AS record_id, *
FROM current_day_record