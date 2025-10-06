{{ config(
    materialized = 'table',
    tags=["dw", "dim"]
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_key']) }} AS customer_id,
    customer_key,
    first_name,
    last_name,
    first_name || ' ' || last_name                            AS full_name,
    email,
    phone,
    address,
    city,
    state,
    postal_code,
    country,
    customer_segment,
    registration_date,
    is_active,
    CURRENT_TIMESTAMP                                         AS dw_created_at,
    CURRENT_TIMESTAMP                                         AS dw_updated_at
FROM {{ ref('prep__dim_customer') }}
