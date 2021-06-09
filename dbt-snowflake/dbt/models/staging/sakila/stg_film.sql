WITH source
AS (
	SELECT sf.film_id,
		sf.title,
		sf.description,
		sf.release_year,
		sl.name AS language,
		slo.name AS original_language,
		sf.rental_duration,
		sf.rental_rate,
		sf.length,
		sf.replacement_cost,
		sf.rating,
		sf.special_features,
		sc.name
	FROM {{ source('sakila', 'film') }} sf
	LEFT JOIN {{ source('sakila', 'film_category') }} sfc ON sfc.film_id = sf.film_id
	LEFT JOIN {{ source('sakila', 'category') }} sc ON sc.category_id = sfc.category_id
	LEFT JOIN {{ source('sakila', 'language') }} sl ON sl.language_id = sf.language_id
	LEFT JOIN {{ source('sakila', 'language') }} slo ON slo.language_id = sf.original_language_id
	),

renamed
AS (
	SELECT film_id,
		title AS film_title,
		description AS film_description,
		release_year AS film_release_year,
		language AS film_language,
		original_language AS film_original_language,
		rental_duration AS film_rental_duration,
		rental_rate AS film_rental_rate,
		length AS film_duration,
		replacement_cost AS film_replacement_cost,
		rating AS film_rating,
		special_features AS film_special_features,
		name AS film_category_name
	FROM source
	)

SELECT *
FROM renamed
