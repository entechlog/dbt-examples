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

renamed
AS (
	SELECT store_id,
		address AS store_address,
		district AS store_district,
		postal_code AS store_postal_code,
		phone AS store_phone_number,
		city AS store_city,
		country AS store_country,
		manager_staff_id AS store_manager_staff_id,
		first_name AS store_manager_first_name,
		last_name AS store_manager_last_name
	FROM source
	)
	
SELECT *
FROM renamed
