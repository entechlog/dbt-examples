{{ config(
    materialized = 'view',
    tags=["prep", "dim"]
) }}

WITH source AS (
    SELECT
        customer_id                                  AS customer_key,
        first_name,
        last_name,
        email,
        phone,
        address,
        city,
        state,
        postal_code,
        country,
        customer_segment,
        CAST(registration_date AS DATE)              AS registration_date,
        is_active
    FROM {{ ref('seed_customers') }}
),

standardize AS (
    SELECT
        customer_key,
        UPPER(TRIM(first_name))                      AS first_name,
        UPPER(TRIM(last_name))                       AS last_name,
        LOWER(TRIM(email))                           AS email,
        phone,
        address,
        city,
        state,
        postal_code,
        country,
        customer_segment,
        registration_date,
        COALESCE(is_active, TRUE)                    AS is_active
    FROM source
),

deduplicated AS (
    SELECT *
    FROM standardize
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY customer_key
        ORDER BY registration_date DESC
    ) = 1
)

SELECT *
FROM deduplicated
