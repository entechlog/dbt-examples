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
		scou.country
	FROM {{ source('raw', 'sakila_customer') }} scus
	LEFT JOIN {{ source('raw', 'sakila_address') }} sadd ON sadd.address_id = scus.address_id
	LEFT JOIN {{ source('raw', 'sakila_city') }} scity ON scity.city_id = sadd.city_id
	LEFT JOIN {{ source('raw', 'sakila_country') }} scou ON scou.country_id = scity.country_id
	),

renamed
AS (
	SELECT customer_id,
		first_name AS customer_first_name,
		last_name AS customer_last_name,
		email AS customer_email,
		active AS customer_active,
		create_date AS customer_created,
		address AS customer_address,
		district AS customer_district,
		postal_code AS customer_postal_code,
		phone AS customer_phone_number,
		city AS customer_city,
		country AS customer_country
	FROM source
	)
	
SELECT *
FROM renamed
