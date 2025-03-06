{% macro fact_purchases_sql() %}

WITH source AS (
    SELECT *
    FROM {{ ref('prep__fact_purchases') }}
         {{ lambda_filter_by_date(src_column_name='event_timestamp', tgt_column_name='event_timestamp') }}
),

relations AS (
    SELECT 
        event_date,
        event_hour,
        event_timestamp,
        store_key,
        product_key,
        product_name,
        quantity,
        unit_price,
        extended_price,
        payment_method,
        purchase_key
    FROM source
)

SELECT *
FROM relations

{% endmacro %}
