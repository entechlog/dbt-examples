{{ config(alias = 'film', materialized='view') }}

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

unioned_with_defaults
AS (
		SELECT {{ dbt_utils.surrogate_key(['film_id']) }} AS film_id ,
		film_id::VARCHAR(100) AS film_key,
		title::VARCHAR(250) AS film_title,
		description::TEXT AS film_description,
		release_year::VARCHAR(4) AS film_release_year,
		language::VARCHAR(100) AS film_language,
		original_language::VARCHAR(100) AS film_original_language,
		rental_duration::INT AS film_rental_duration,
		rental_rate::FLOAT AS film_rental_rate,
		length::INT AS film_duration,
		replacement_cost::FLOAT AS film_replacement_cost,
		rating::VARCHAR(10) AS film_rating,
		special_features::VARCHAR(250) AS film_special_features,
		name::VARCHAR(100) AS film_category_name
	FROM source	
	UNION
	
	SELECT '0' AS film_id ,
		'[Unknown]'::VARCHAR(100) AS film_key,
		'[Unknown]'::VARCHAR(250) AS film_title,
		'[Unknown]'::TEXT AS film_description,
		NULL::VARCHAR(4) AS film_release_year,
		'[Unknown]'::VARCHAR(100) AS film_language,
		'[Unknown]'::VARCHAR(100) AS film_original_language,
		NULL::INT AS film_rental_duration,
		NULL::FLOAT AS film_rental_rate,
		NULL::INT AS film_duration,
		NULL::FLOAT AS film_replacement_cost,
		'[Unknown]'::VARCHAR(10) AS film_rating,
		'[Unknown]'::VARCHAR(250) AS film_special_features,
		'[Unknown]'::VARCHAR(100) AS film_category_name
	
	UNION
	
	SELECT '1' AS film_id,
		'[NotApplicable]'::VARCHAR(100) AS film_key,
		'[NotApplicable]'::VARCHAR(250) AS film_title,
		'[NotApplicable]'::TEXT AS film_description,
		NULL::VARCHAR(4) AS film_release_year,
		'[NotApplicable]'::VARCHAR(100) AS film_language,
		'[NotApplicable]'::VARCHAR(100) AS film_original_language,
		NULL::INT AS film_rental_duration,
		NULL::FLOAT AS film_rental_rate,
		NULL::INT AS film_duration,
		NULL::FLOAT AS film_replacement_cost,
		'[NotApplicable]'::VARCHAR(10) AS film_rating,
		'[NotApplicable]'::VARCHAR(250) AS film_special_features,
		'[NotApplicable]'::VARCHAR(100) AS film_category_name
	
	UNION
	
	SELECT '2' AS film_id,
		'[All]'::VARCHAR(100) AS film_key,
		'[All]'::VARCHAR(250) AS film_title,
		'[All]'::TEXT AS film_description,
		NULL::VARCHAR(4) AS film_release_year,
		'[All]'::VARCHAR(100) AS film_language,
		'[All]'::VARCHAR(100) AS film_original_language,
		NULL::INT AS film_rental_duration,
		NULL::FLOAT AS film_rental_rate,
		NULL::INT AS film_duration,
		NULL::FLOAT AS film_replacement_cost,
		'[All]'::VARCHAR(10) AS film_rating,
		'[All]'::VARCHAR(250) AS film_special_features,
		'[All]'::VARCHAR(100) AS film_category_name
	),

deduplicated AS (
		SELECT req.*
		FROM (
			SELECT *,
				row_number() OVER (
					PARTITION BY film_key ORDER BY film_id, film_title DESC
					) AS seq
			FROM unioned_with_defaults
			) req
		WHERE seq = 1
		)

SELECT *
FROM deduplicated