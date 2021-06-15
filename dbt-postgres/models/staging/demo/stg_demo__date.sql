{{ config(alias = 'date', materialized='view') }}

WITH source
AS (
	SELECT *
	FROM {{ source('demo', 'd_date') }}
	)

SELECT *
FROM source
