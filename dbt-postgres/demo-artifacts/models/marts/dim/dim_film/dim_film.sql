{{ config(alias = 'film', materialized='table') }}

SELECT *
FROM {{ ref('stg_sakila__film') }}