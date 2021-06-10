{{
    config(
        materialized='view'
    )
}}

SELECT *
FROM {{ ref('stg_customer') }} scus