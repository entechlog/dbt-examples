{{ config(alias = 'staff', materialized='view') }}

WITH source
AS (
	SELECT sstaff.staff_id,
		sstaff.first_name,
		sstaff.last_name,
		sstore.store_id,
		sstaff.active
	FROM {{ source('sakila', 'staff') }} sstaff
	LEFT JOIN {{ source('sakila', 'store') }} sstore ON sstore.store_id = sstaff.store_id
	),

unioned_with_defaults
AS (
	SELECT {{ dbt_utils.surrogate_key(['staff_id']) }} AS staff_id,
		staff_id::VARCHAR(100) AS staff_key,
		first_name::VARCHAR(100) AS staff_first_name,
		last_name::VARCHAR(100) AS staff_last_name,
		store_id::INT AS staff_store_id,
		active::INT AS staff_active
	FROM source
	
	UNION
	
	SELECT '0' AS staff_id,
		'[Unknown]'::VARCHAR(100) AS staff_key,
		'[Unknown]'::VARCHAR(100) AS staff_first_name,
		'[Unknown]'::VARCHAR(100) AS staff_last_name,
		NULL::INT AS staff_store_id,
		NULL::INT AS staff_active
	
	UNION
	
	SELECT '1' AS staff_id,
		'[NotApplicable]'::VARCHAR(100) AS staff_key,
		'[NotApplicable]'::VARCHAR(100) AS staff_first_name,
		'[NotApplicable]'::VARCHAR(100) AS staff_last_name,
		NULL::INT AS staff_store_id,
		NULL::INT AS staff_active
	
	UNION
	
	SELECT '2' AS staff_id,
		'[All]'::VARCHAR(100) AS staff_key,
		'[All]'::VARCHAR(100) AS staff_first_name,
		'[All]'::VARCHAR(100) AS staff_last_name,
		NULL::INT AS staff_store_id,
		NULL::INT AS staff_active
	),

deduplicated
AS (
	SELECT req.*
	FROM (
		SELECT *,
			row_number() OVER (
				PARTITION BY staff_key ORDER BY staff_id,
					staff_last_name DESC
				) AS seq
		FROM unioned_with_defaults
		) req
	WHERE seq = 1
	)

SELECT *
FROM deduplicated
