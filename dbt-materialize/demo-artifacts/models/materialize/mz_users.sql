{{ config(
    materialized = 'materializedview', 
    alias = 'mz_users', 
    tags = ["materialized"]
) }}

SELECT to_char(event_timestamp, 'YYYYMMDD') AS event_date,
	gender,
	count(gender)
FROM {{ ref('src_kafka__users') }}
GROUP BY event_date,
	gender
