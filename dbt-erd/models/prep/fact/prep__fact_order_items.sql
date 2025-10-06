{{ config(
    materialized = 'view',
    tags=["prep", "fact"]
) }}

WITH source AS (
    SELECT
        order_item_id                                AS order_item_key,
        order_id                                     AS order_key,
        product_id                                   AS product_key,
        CAST(quantity AS INTEGER)                    AS quantity,
        CAST(unit_price AS DECIMAL(10,2))           AS unit_price,
        CAST(line_total AS DECIMAL(10,2))           AS line_total,
        CAST(discount_amount AS DECIMAL(10,2))      AS discount_amount,
        CAST(created_timestamp AS TIMESTAMP)         AS created_timestamp
    FROM {{ ref('seed_order_items') }}
),

standardize AS (
    SELECT
        order_item_key,
        order_key,
        product_key,
        quantity,
        unit_price,
        line_total,
        discount_amount,
        created_timestamp,
        CAST(created_timestamp AS DATE)              AS order_date
    FROM source
),

deduplicated AS (
    SELECT *
    FROM standardize
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY order_item_key
        ORDER BY created_timestamp DESC
    ) = 1
)

SELECT *
FROM deduplicated
