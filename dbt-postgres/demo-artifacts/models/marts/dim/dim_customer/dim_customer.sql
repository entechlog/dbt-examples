{{ config(alias = 'customer', materialized='table') }}

SELECT *
FROM {{ ref('stg_sakila__customer') }}