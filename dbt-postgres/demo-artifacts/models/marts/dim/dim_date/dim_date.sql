{{ config(alias = 'date', materialized='table') }}

SELECT *
FROM {{ ref('stg_demo__date') }}