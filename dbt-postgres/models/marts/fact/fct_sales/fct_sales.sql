{{ config(
    alias = 'sales', 
    materialized = 'incremental', 
    transient=false,
    tags=["fact","daily"],
    pre_hook = "{{ delete_data('date_id', var('start_date') | replace('-', ''), this) }}"
    ) }}

WITH source
AS (
	SELECT *
	FROM {{ ref('stg_sakila__sales') }}
	{% if is_incremental() %}
		WHERE DATE(payment_date) = {{ "'" ~ var('start_date') ~ "'" }}
	{% endif %}
	),

relations
AS (
	SELECT COALESCE(dd.date_dim_id, '0') AS date_id,
		COALESCE(dc.customer_id, '0') AS customer_id,
		COALESCE(df.film_id, '0') AS film_id,
		COALESCE(ds.store_id, '0') AS store_id,
		COALESCE(dst.staff_id, '0') AS staff_id,
		amount
	FROM source src
	LEFT JOIN {{ ref('dim_customer') }} dc ON src.customer_key = dc.customer_key
	LEFT JOIN {{ ref('dim_date') }} dd ON DATE (src.payment_date) = dd.date_actual
	LEFT JOIN {{ ref('dim_store') }} ds ON src.store_key = ds.store_key
	LEFT JOIN {{ ref('dim_film') }} df ON src.film_key = df.film_key
	LEFT JOIN {{ ref('dim_staff') }} dst ON src.staff_key = dst.staff_key
	)

SELECT *
FROM relations
