{% macro get_audit_database() %}

   {{ return(var('logging_db')) }}

{% endmacro %}

{% macro get_audit_schema() %}

   {{ return(var('logging_schema')) }}

{% endmacro %}

{% macro get_audit_relation() %}

    {%- set audit_schema=get_audit_schema() -%}
    {%- set audit_database=get_audit_database() -%}

    {%- set audit_table =
        api.Relation.create(
            database=audit_database,
            schema=audit_schema,
            identifier='dbt_audit_log',
            type='table'
        ) -%}
    
    {{ return(audit_table) }}

{% endmacro %}


{% macro log_audit_event(event_name, schema, relation, user, target_name, is_full_refresh) -%}

  {{ return(adapter.dispatch('log_audit_event')(event_name, schema, relation, user, target_name, is_full_refresh)) }}

{% endmacro %}

{% macro default__log_audit_event(event_name, schema, relation, user, target_name, is_full_refresh) %}

    insert into {{ get_audit_relation() }} (
        event_name,
        event_timestamp,
        event_schema,
        event_model,
        event_user,
        event_target,
        event_is_full_refresh,
        invocation_id
    )

    values (
        '{{ event_name }}',
        {{ dbt_utils.current_timestamp_in_utc() }},
        {% if schema != None %}'{{ schema }}'{% else %}null::varchar(512){% endif %},
        {% if relation != None %}'{{ relation }}'{% else %}null::varchar(512){% endif %},
        {% if user != None %}'{{ user }}'{% else %}null::varchar(512){% endif %},
        {% if target_name != None %}'{{ target_name }}'{% else %}null::varchar(512){% endif %},
        {% if is_full_refresh %}TRUE{% else %}FALSE{% endif %},
        '{{ invocation_id }}'
    );

    commit;

{% endmacro %}


{% macro create_audit_schema() %}
    {% do create_schema(api.Relation.create(
        database=get_audit_database(),
        schema=get_audit_schema())
    ) %}
{% endmacro %}


{% macro create_audit_log_table() -%}

    {{ return(adapter.dispatch('create_audit_log_table')()) }}

{% endmacro %}


{% macro default__create_audit_log_table() -%}

    {% set required_columns = [
       ["event_name", dbt_utils.type_string()],
       ["event_timestamp", dbt_utils.type_timestamp()],
       ["event_schema", dbt_utils.type_string()],
       ["event_model", dbt_utils.type_string()],
       ["event_user", dbt_utils.type_string()],
       ["event_target", dbt_utils.type_string()],
       ["event_is_full_refresh", "boolean"],
       ["invocation_id", dbt_utils.type_string()],
    ] -%}

    {% set audit_table = get_audit_relation() -%}

    {% set audit_table_exists = adapter.get_relation(audit_table.database, audit_table.schema, audit_table.name) -%}


    {% if audit_table_exists -%}

        {%- set columns_to_create = [] -%}

        {# map to lower to cater for snowflake returning column names as upper case #}
        {%- set existing_columns = adapter.get_columns_in_relation(audit_table)|map(attribute='column')|map('lower')|list -%}

        {%- for required_column in required_columns -%}
            {%- if required_column[0] not in existing_columns -%}
                {%- do columns_to_create.append(required_column) -%}

            {%- endif -%}
        {%- endfor -%}


        {%- for column in columns_to_create -%}
            alter table {{ audit_table }}
            add column {{ column[0] }} {{ column[1] }}
            default null;
        {% endfor -%}

        {%- if columns_to_create|length > 0 %}
            commit;
        {% endif -%}

    {%- else -%}
        create table if not exists {{ audit_table }}
        (
        {% for column in required_columns %}
            {{ column[0] }} {{ column[1] }}{% if not loop.last %},{% endif %}
        {% endfor %}
        )
    {%- endif -%}

{%- endmacro %}


{% macro log_run_start_event() %}
    {{ log_audit_event('run started', user=target.user, target_name=target.name, is_full_refresh=flags.FULL_REFRESH) }}
{% endmacro %}


{% macro log_run_end_event() %}
    {{ log_audit_event('run completed', user=target.user, target_name=target.name, is_full_refresh=flags.FULL_REFRESH) }}
{% endmacro %}


{% macro log_model_start_event() %}
    {{ log_audit_event(
        'model deployment started', schema=this.schema, relation=this.name, user=target.user, target_name=target.name, is_full_refresh=flags.FULL_REFRESH
    ) }}
{% endmacro %}


{% macro log_model_end_event() %}
    {{ log_audit_event(
        'model deployment completed', schema=this.schema, relation=this.name, user=target.user, target_name=target.name, is_full_refresh=flags.FULL_REFRESH
    ) }}
{% endmacro %}


{% macro log_custom_event(event_name) %}
    {{ log_audit_event(
        event_name, schema=this.schema, relation=this.name, user=target.user, target_name=target.name, is_full_refresh=flags.FULL_REFRESH
    ) }}
{% endmacro %}