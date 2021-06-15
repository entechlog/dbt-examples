{{ config(
    alias = 'store', 
    materialized = 'view',
    tags=["presentation-dim","daily"]
    ) }}

WITH source
AS (
    SELECT *
    FROM {{ ref('dim_store') }}
    )

SELECT *
FROM source