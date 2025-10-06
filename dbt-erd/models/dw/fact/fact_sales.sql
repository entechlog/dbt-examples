{{ config(
    materialized = 'table',
    tags=["dw", "fact"]
) }}

WITH order_items AS (
    SELECT * FROM {{ ref('prep__fact_order_items') }}
),

products AS (
    SELECT * FROM {{ ref('dim_product') }}
),

customers AS (
    SELECT * FROM {{ ref('dim_customer') }}
),

sales_detail AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['oi.order_item_key']) }} AS sales_id,
        oi.order_item_key,
        oi.order_key,
        oi.product_key,
        p.product_id,
        -- Get customer from first item of order (simplified logic)
        NULL                                         AS customer_key,
        d.date_id                                    AS sale_date_id,
        oi.order_date                                AS sale_date,
        oi.created_timestamp                         AS sale_timestamp,
        oi.quantity                                  AS quantity_sold,
        oi.unit_price,
        oi.line_total                                AS gross_sales,
        oi.discount_amount,
        oi.line_total - oi.discount_amount           AS net_sales,
        p.unit_cost,
        p.unit_cost * oi.quantity                    AS total_cost,
        (oi.line_total - oi.discount_amount) - (p.unit_cost * oi.quantity) AS profit,
        CASE
            WHEN (oi.line_total - oi.discount_amount) > 0
            THEN (((oi.line_total - oi.discount_amount) - (p.unit_cost * oi.quantity)) /
                  (oi.line_total - oi.discount_amount)) * 100
            ELSE 0
        END                                          AS profit_margin_percentage,
        p.product_category,
        p.product_subcategory,
        p.brand,
        CURRENT_TIMESTAMP                            AS dw_created_at,
        CURRENT_TIMESTAMP                            AS dw_updated_at
    FROM order_items oi
    LEFT JOIN products p
        ON oi.product_key = p.product_key
    LEFT JOIN {{ ref('dim_date') }} d
        ON oi.order_date = d.date_actual
)

SELECT *
FROM sales_detail
