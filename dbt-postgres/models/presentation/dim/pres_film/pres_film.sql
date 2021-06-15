{{ config(
    alias = 'film', 
    materialized = 'view',
    tags=["presentation-dim","daily"]
    ) }}

WITH source
AS (
    SELECT *
    FROM {{ ref('dim_film') }}
    )

SELECT *
FROM source