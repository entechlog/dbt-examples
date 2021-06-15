{{ config(alias = 'store', materialized='table') }}

SELECT *
FROM {{ ref('stg_sakila__store') }}