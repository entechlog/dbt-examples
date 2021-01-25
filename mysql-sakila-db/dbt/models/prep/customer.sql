WITH source
AS (
	SELECT scus.customer_id,
		scus.store_id,
		scus.first_name,
		scus.last_name,
		scus.email,
		scus.address_id,
		scus.active,
		scus.create_date,
		sadd.address,
		sadd.address2,
		sadd.district,
		sadd.city_id,
		sadd.postal_code,
		sadd.phone,
		scity.city,
		scity.country_id,
		scou.country
	FROM {{ source('raw', 'sakila_customer') }} scus
	LEFT JOIN {{ source('raw', 'sakila_address') }} sadd using (address_id)
	LEFT JOIN {{ source('raw', 'sakila_city') }} scity using (city_id)
	LEFT JOIN {{ source('raw', 'sakila_country') }} scou using (country_id)
	),

renamed
AS (
	SELECT customer_id,
		first_name as customer_first_name,
		last_name as customer_last_name,
		email as customer_email,
		active as customer_active,
		create_date AS customer_created,
		address as customer_address,
		district as customer_district,
		postal_code as customer_postal_code,
		phone AS customer_phone_number,
		city as customer_city,
		country as customer_country
	FROM source
	)

SELECT *
FROM renamed
