{{ config(alias = 'staff', materialized='table') }}

SELECT *
FROM {{ ref('stg_sakila__staff') }}