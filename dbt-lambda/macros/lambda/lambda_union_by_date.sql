{% macro lambda_union_by_date(historical_relation, model_sql,tgt_timestamp_column) %}

{% set unique_key = config.get('unique_key', none) %}

with historical as (

    select *
      {#  ,'dw' as _dbt_lambda_view_source, #}
       {#  ({{ get_max_timestamp(historical_relation,tgt_timestamp_column) }}) as _dbt_last_run_at #}

    from {{ historical_relation }}

),

new_raw as (

    {{ model_sql }}

),

new as (

    select *
       {# ,'raw' as _dbt_lambda_view_source, #}
      {# {{ dbt_utils.current_timestamp() }} as _dbt_last_run_at #}

    from new_raw

),

unioned as (

    select * from historical

    {% if unique_key %}

        where {{ unique_key }} not in (
            select {{ unique_key }} from new
        )

    {% endif %}

    union

    select * from new

)

select * from unioned

{% endmacro %}