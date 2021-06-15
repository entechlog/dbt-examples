{{ config(alias = 'customer', materialized='view') }}

WITH source
AS (
	SELECT scus.customer_id,
		scus.store_id,
		scus.first_name,
		scus.last_name,
		scus.email,
		scus.active,
		scus.create_date,
		sadd.address,
		sadd.district,
		sadd.postal_code,
		sadd.phone,
		scity.city,
		scou.country,
		scus.last_update
	FROM {{ source('sakila', 'customer') }} scus
	LEFT JOIN {{ source('sakila', 'address') }} sadd ON sadd.address_id = scus.address_id
	LEFT JOIN {{ source('sakila', 'city') }} scity ON scity.city_id = sadd.city_id
	LEFT JOIN {{ source('sakila', 'country') }} scou ON scou.country_id = scity.country_id
	),

unioned_with_defaults
AS (
	SELECT {{ dbt_utils.surrogate_key(['customer_id']) }} AS customer_id,
		customer_id::VARCHAR(100) AS customer_key,
		first_name::VARCHAR(100) AS customer_first_name,
		last_name::VARCHAR(100) AS customer_last_name,
		email::VARCHAR(100) AS customer_email,
		active::INT AS customer_active,
		create_date::DATE AS customer_created,
		address::VARCHAR(100) AS customer_address,
		district::VARCHAR(100) AS customer_district,
		postal_code::VARCHAR(50) AS customer_postal_code,
		phone::VARCHAR(50) AS customer_phone_number,
		city::VARCHAR(50) AS customer_city,
		country::VARCHAR(50) AS customer_country,
		last_update::TIMESTAMP
	FROM source
	
	UNION
	
	SELECT '0' AS customer_id,
		'[Unknown]'::VARCHAR(100) AS customer_key,
		'[Unknown]'::VARCHAR(100) AS customer_first_name,
		'[Unknown]'::VARCHAR(100) AS customer_last_name,
		'[Unknown]'::VARCHAR(100) AS customer_email,
		NULL::INT AS customer_active,
		NULL::DATE AS customer_created,
		'[Unknown]'::VARCHAR(100) AS customer_address,
		'[Unknown]'::VARCHAR(100) AS customer_district,
		'[Unknown]'::VARCHAR(50) AS customer_postal_code,
		'[Unknown]'::VARCHAR(50) AS customer_phone_number,
		'[Unknown]'::VARCHAR(50) AS customer_city,
		'[Unknown]'::VARCHAR(50) AS customer_country,
		NULL::TIMESTAMP AS last_update
	
	UNION
	
	SELECT '1' AS customer_id,
		'[NotApplicable]'::VARCHAR(100) AS customer_key,
		'[NotApplicable]'::VARCHAR(100) AS customer_first_name,
		'[NotApplicable]'::VARCHAR(100) AS customer_last_name,
		'[NotApplicable]'::VARCHAR(100) AS customer_email,
		NULL::INT AS customer_active,
		NULL::DATE AS customer_created,
		'[NotApplicable]'::VARCHAR(100) AS customer_address,
		'[NotApplicable]'::VARCHAR(100) AS customer_district,
		'[NotApplicable]'::VARCHAR(50) AS customer_postal_code,
		'[NotApplicable]'::VARCHAR(50) AS customer_phone_number,
		'[NotApplicable]'::VARCHAR(50) AS customer_city,
		'[NotApplicable]'::VARCHAR(50) AS customer_country,
		NULL::TIMESTAMP AS last_update
	
	UNION
	
	SELECT '2' AS customer_id,
		'[All]'::VARCHAR(100) AS customer_key,
		'[All]'::VARCHAR(100) AS customer_first_name,
		'[All]'::VARCHAR(100) AS customer_last_name,
		'[All]'::VARCHAR(100) AS customer_email,
		NULL::INT AS customer_active,
		NULL::DATE AS customer_created,
		'[All]'::VARCHAR(100) AS customer_address,
		'[All]'::VARCHAR(100) AS customer_district,
		'[All]'::VARCHAR(50) AS customer_postal_code,
		'[All]'::VARCHAR(50) AS customer_phone_number,
		'[All]'::VARCHAR(50) AS customer_city,
		'[All]'::VARCHAR(50) AS customer_country,
		NULL::TIMESTAMP AS last_update
	),

deduplicated AS (
		SELECT req.*
		FROM (
			SELECT *,
				row_number() OVER (
					PARTITION BY customer_key ORDER BY customer_id, customer_last_name DESC
					) AS seq
			FROM unioned_with_defaults
			) req
		WHERE seq = 1
		)

SELECT *
FROM deduplicated
