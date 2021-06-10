{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key='customer_id'
    )
}}

SELECT *
FROM {{ ref('stg_customer') }} scus

{% if is_incremental() %}
	HAVING scus.last_update > (select max(last_update) from {{ this }})
{% endif %}
