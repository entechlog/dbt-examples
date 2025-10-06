{{ config(
    materialized = 'table',
    tags=["dw", "fact"]
) }}

WITH order_items AS (
    SELECT * FROM {{ ref('prep__fact_order_items') }}
),

order_summary AS (
    SELECT
        order_key,
        MIN(order_date)                              AS order_date,
        MIN(created_timestamp)                       AS order_timestamp,
        COUNT(DISTINCT order_item_key)               AS item_count,
        SUM(quantity)                                AS total_quantity,
        SUM(line_total)                              AS subtotal,
        SUM(discount_amount)                         AS discount_amount,
        SUM(line_total - discount_amount)            AS order_total
    FROM order_items
    GROUP BY order_key
),

enriched AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['o.order_key']) }} AS order_id,
        o.order_key,
        d.date_id                                    AS order_date_id,
        o.order_date,
        o.order_timestamp,
        o.item_count,
        o.total_quantity,
        o.subtotal,
        o.discount_amount,
        o.order_total,
        CASE
            WHEN o.discount_amount > 0 THEN (o.discount_amount / o.subtotal) * 100
            ELSE 0
        END                                          AS discount_percentage,
        CURRENT_TIMESTAMP                            AS dw_created_at,
        CURRENT_TIMESTAMP                            AS dw_updated_at
    FROM order_summary o
    LEFT JOIN {{ ref('dim_date') }} d
        ON o.order_date = d.date_actual
)

SELECT *
FROM enriched
