{{ config(
    alias = 'purchases', 
    materialized = 'incremental',
    transient = false,
    tags = ["dw","fact"],
    cluster_by = ['event_date'],
    on_schema_change = 'sync_all_columns',
    pre_hook = "{{ delete_data('event_date', var('batch_cycle_date'), this) }}"
) }}

{{ fact_purchases_sql() }}
