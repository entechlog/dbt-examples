{{ config(
    alias = 'staff', 
    materialized = 'view',
    tags=["presentation-dim","daily"]
    ) }}

WITH source
AS (
    SELECT *
    FROM {{ ref('dim_staff') }}
    )

SELECT *
FROM source