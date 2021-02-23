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

renamed
AS (
	SELECT staff_id,
		first_name AS staff_first_name,
		last_name AS staff_last_name,
		store_id AS staff_store_id,
		active AS staff_active
	FROM source
	)
	
SELECT *
FROM renamed
