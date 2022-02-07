{{ config(
    materialized = 'view', 
    alias = 'stg_users', 
    tags = ["staging"]
) }}

SELECT registertime,
	userid,
	regionid,
	gender
FROM {{ ref('src_kafka__users') }}
