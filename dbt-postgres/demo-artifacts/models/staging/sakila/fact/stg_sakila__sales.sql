{{ config(alias = 'sales', materialized='view') }}

WITH source
AS (
    SELECT sp.payment_id,
    sp.customer_id,
    si.film_id,
    si.store_id,
    sp.staff_id,
    sp.payment_date,
    sp.amount
    FROM {{ ref('payment') }} sp
    LEFT JOIN {{ ref('rental') }} sr ON sp.rental_id = sr.rental_id
    LEFT JOIN {{ ref('inventory') }} si ON sr.inventory_id = si.inventory_id
),

renamed
AS (
    SELECT src.payment_id::VARCHAR(100) AS payment_key,
    src.customer_id::VARCHAR(100) AS customer_key,
    src.film_id::VARCHAR(100) AS film_key,
    src.store_id::VARCHAR(100) AS store_key,
    src.staff_id::VARCHAR(100) AS staff_key,
    src.payment_date::TIMESTAMP as payment_date,
    src.amount::FLOAT AS amount
    FROM source src
)

SELECT *
FROM renamed