{{ config(alias = 'store', materialized='view') }}

WITH source
AS (
	SELECT ss.store_id,
		sadd.address,
		sadd.district,
		sadd.postal_code,
		sadd.phone,
		scity.city,
		scou.country,
		ss.manager_staff_id,
		sstaff.first_name,
		sstaff.last_name
	FROM {{ source('sakila', 'store') }} ss
	LEFT JOIN {{ source('sakila', 'address') }} sadd ON sadd.address_id = ss.address_id
	LEFT JOIN {{ source('sakila', 'city') }} scity ON scity.city_id = sadd.city_id
	LEFT JOIN {{ source('sakila', 'country') }} scou ON scou.country_id = scity.country_id
	LEFT JOIN {{ source('sakila', 'staff') }} sstaff ON sstaff.staff_id = ss.manager_staff_id
	),

unioned_with_defaults
AS (
		SELECT {{ dbt_utils.surrogate_key(['store_id']) }} AS store_id,
		store_id::VARCHAR(100) AS store_key,
		address::VARCHAR(100) AS store_address,
		district::VARCHAR(100) AS store_district,
		postal_code::VARCHAR(50) AS store_postal_code,
		phone::VARCHAR(50) AS store_phone_number,
		city::VARCHAR(50) AS store_city,
		country::VARCHAR(50) AS store_country,
		manager_staff_id::VARCHAR(100) AS store_manager_staff_key,
		first_name::VARCHAR(100) AS store_manager_first_name,
		last_name::VARCHAR(100) AS store_manager_last_name
	FROM source
	
	UNION
	
	SELECT '0' AS store_id,
		'[Unknown]'::VARCHAR(100) AS store_key,
		'[Unknown]'::VARCHAR(100) AS store_address,
		'[Unknown]'::VARCHAR(100) AS store_district,
		'[Unknown]'::VARCHAR(50) AS store_postal_code,
		'[Unknown]'::VARCHAR(50) AS store_phone_number,
		'[Unknown]'::VARCHAR(50) AS store_city,
		'[Unknown]'::VARCHAR(50) AS store_country,
		'[Unknown]'::VARCHAR(100) AS store_manager_staff_key,
		'[Unknown]'::VARCHAR(100) AS store_manager_first_name,
		'[Unknown]'::VARCHAR(100) AS store_manager_last_name
	
	UNION
	
	SELECT '1' AS store_id,
		'[NotApplicable]'::VARCHAR(100) AS store_key,
		'[NotApplicable]'::VARCHAR(100) AS store_address,
		'[NotApplicable]'::VARCHAR(100) AS store_district,
		'[NotApplicable]'::VARCHAR(50) AS store_postal_code,
		'[NotApplicable]'::VARCHAR(50) AS store_phone_number,
		'[NotApplicable]'::VARCHAR(50) AS store_city,
		'[NotApplicable]'::VARCHAR(50) AS store_country,
		'[NotApplicable]'::VARCHAR(100) AS store_manager_staff_key,
		'[NotApplicable]'::VARCHAR(100) AS store_manager_first_name,
		'[NotApplicable]'::VARCHAR(100) AS store_manager_last_name
	
	UNION
	
	SELECT '2' AS store_id,
		'[All]'::VARCHAR(100) AS store_key,
		'[All]'::VARCHAR(100) AS store_address,
		'[All]'::VARCHAR(100) AS store_district,
		'[All]'::VARCHAR(50) AS store_postal_code,
		'[All]'::VARCHAR(50) AS store_phone_number,
		'[All]'::VARCHAR(50) AS store_city,
		'[All]'::VARCHAR(50) AS store_country,
		'[All]'::VARCHAR(100) AS store_manager_staff_key,
		'[All]'::VARCHAR(100) AS store_manager_first_name,
		'[All]'::VARCHAR(100) AS store_manager_last_name
	),

deduplicated
AS (
	SELECT req.*
	FROM (
		SELECT *,
			row_number() OVER (
				PARTITION BY store_key ORDER BY store_id,
					store_address DESC
				) AS seq
		FROM unioned_with_defaults
		) req
	WHERE seq = 1
	)

SELECT *
FROM deduplicated
