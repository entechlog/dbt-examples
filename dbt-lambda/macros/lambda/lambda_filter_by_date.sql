{% macro lambda_filter_by_date(src_column_name, tgt_column_name) %}

    {% set materialized = config.require('materialized') %}
    {% set filter_time = var('lambda_split', run_started_at) %}

    {% if materialized == 'view' %}

        where {{ src_column_name }} >= (select max({{ tgt_column_name }}) from {{ this | replace('.OBT.', '.FACT.') }})

    {% elif is_incremental() %}

        where DATE({{ src_column_name }}) = '{{ var("batch_cycle_date") }}'

    {% else %}

        where {{ src_column_name }} < '{{ filter_time }}'

    {% endif %}

{% endmacro %}