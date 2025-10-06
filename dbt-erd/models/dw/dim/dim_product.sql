{{ config(
    materialized = 'table',
    tags=["dw", "dim"]
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_key']) }} AS product_id,
    product_key,
    product_name,
    product_category,
    product_subcategory,
    brand,
    unit_price,
    unit_cost,
    unit_price - unit_cost                                   AS unit_margin,
    CASE
        WHEN unit_price > 0 THEN ((unit_price - unit_cost) / unit_price) * 100
        ELSE 0
    END                                                       AS margin_percentage,
    supplier_key,
    stock_quantity,
    reorder_level,
    CASE
        WHEN stock_quantity <= reorder_level THEN TRUE
        ELSE FALSE
    END                                                       AS needs_reorder,
    is_active,
    created_date,
    CURRENT_TIMESTAMP                                         AS dw_created_at,
    CURRENT_TIMESTAMP                                         AS dw_updated_at
FROM {{ ref('prep__dim_product') }}
