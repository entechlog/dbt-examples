{{ config(
    alias = 'customer', 
    materialized = 'view',
    tags=["presentation-dim","daily"]
    ) }}

WITH source
AS (
    SELECT *
    FROM {{ ref('dim_customer') }}
    )

SELECT *
FROM source