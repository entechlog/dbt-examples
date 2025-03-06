{{ config(
    alias = 'purchases', 
	materialized = 'view',
	tags=["dw","obt"]
	) }}

{{ lambda_union_by_date(
    historical_relation = ref('dw__fact_purchases'),
    model_sql = fact_purchases_sql(),
    tgt_timestamp_column = 'event_timestamp'
) }}