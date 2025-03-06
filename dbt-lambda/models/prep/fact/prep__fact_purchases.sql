{{ config(
    alias = 'purchases', 
    materialized = 'view',
    tags=["prep","fact"]
) }}

WITH source AS (
    SELECT
        -- Convert your transaction_timestamp to date/hour/timestamp
        TO_DATE(transaction_timestamp)               AS event_date,
        EXTRACT(HOUR FROM transaction_timestamp)     AS event_hour,
        CAST(transaction_timestamp AS TIMESTAMP)     AS event_timestamp,

        -- Rename _id to _key, as we use _key for natural key and _id for surrogate id
        store_id                                     AS store_key,

        -- Product info
        product_id                                   AS product_key,
        product_name,

        -- Fact metrics
        CAST(quantity AS NUMBER(10,0))               AS quantity,
        CAST(unit_price AS NUMBER(10,2))             AS unit_price,
        CAST(extended_price AS NUMBER(10,2))         AS extended_price,
        payment_method                               AS payment_method,

        -- Original ID (for partitioning dedup logic)
        purchase_id                                  AS purchase_key
    FROM {{ source('seed', 'purchases') }}
),

standardize AS (
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
),

deduplicated AS (
    SELECT *
    FROM standardize
    -- Keep only the most recent row per partition (if duplicates exist).
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY
            purchase_key
        ORDER BY event_timestamp DESC
    ) = 1
)

SELECT *
FROM deduplicated
