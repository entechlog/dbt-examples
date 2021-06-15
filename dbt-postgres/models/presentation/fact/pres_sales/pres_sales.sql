{{ config(
    alias = 'sales', 
    materialized = 'view',
    tags=["presentation-fact","daily"]
    ) }}

WITH source
AS (
    SELECT *
    FROM {{ ref('fct_sales') }}
    )

SELECT *
FROM source