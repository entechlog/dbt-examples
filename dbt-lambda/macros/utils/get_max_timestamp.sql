{% macro get_max_timestamp(model, timestamp_column) %}
 
  select
    TRY_TO_TIMESTAMP(max({{ timestamp_column }})::VARCHAR)::timestamp as max_timestamp
  from {{ model }}
 
{% endmacro %}