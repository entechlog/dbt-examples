{{ config(
    alias = 'date', 
    materialized = 'view',
    tags=["presentation-dim","daily"]
    ) }}

WITH source
AS (
    SELECT *
    FROM {{ ref('dim_date') }}
    )

SELECT *
FROM source