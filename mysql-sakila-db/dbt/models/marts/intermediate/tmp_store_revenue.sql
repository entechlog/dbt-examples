with payment as (

    select * from {{ ref('payment') }}

),

final as (

	SELECT payment_date
		,amount
		,sum(amount) OVER (
			ORDER BY payment_date
			) as sum
	FROM (
		SELECT CAST(payment_date AS DATE) AS payment_date
			,SUM(amount) AS amount
		FROM payment
		GROUP BY CAST(payment_date AS DATE)
		) p
	ORDER BY payment_date

)

select * from final
