{{ config(
    materialized = 'view',
    tags=["prep", "dim"]
) }}

WITH source AS (
    SELECT
        product_id                                   AS product_key,
        product_name,
        product_category,
        product_subcategory,
        brand,
        CAST(unit_price AS DECIMAL(10,2))           AS unit_price,
        CAST(unit_cost AS DECIMAL(10,2))            AS unit_cost,
        supplier_id                                  AS supplier_key,
        CAST(stock_quantity AS INTEGER)              AS stock_quantity,
        CAST(reorder_level AS INTEGER)               AS reorder_level,
        is_active,
        CAST(created_date AS DATE)                   AS created_date
    FROM {{ ref('seed_products') }}
),

standardize AS (
    SELECT
        product_key,
        TRIM(product_name)                           AS product_name,
        UPPER(TRIM(product_category))                AS product_category,
        UPPER(TRIM(product_subcategory))             AS product_subcategory,
        UPPER(TRIM(brand))                           AS brand,
        unit_price,
        unit_cost,
        supplier_key,
        stock_quantity,
        reorder_level,
        COALESCE(is_active, TRUE)                    AS is_active,
        created_date
    FROM source
),

deduplicated AS (
    SELECT *
    FROM standardize
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY product_key
        ORDER BY created_date DESC
    ) = 1
)

SELECT *
FROM deduplicated
