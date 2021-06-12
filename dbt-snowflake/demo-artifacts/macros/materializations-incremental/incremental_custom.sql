{% macro dbt_snowflake_validate_get_incremental_strategy(config) %}
  {#-- Find and validate the incremental strategy #}
  {%- set strategy = config.get("incremental_strategy", default="merge") -%}
 
  {% set invalid_strategy_msg -%}
    Invalid incremental strategy provided: {{ strategy }}
    Expected one of: 'merge', 'delete+insert'
  {%- endset %}
  {% if strategy not in ['merge', 'delete+insert'] %}
    {% do exceptions.raise_compiler_error(invalid_strategy_msg) %}
  {% endif %}
 
  {% do return(strategy) %}
{% endmacro %}
 
{% macro dbt_snowflake_get_incremental_sql(strategy, tmp_relation, target_relation, unique_key, dest_columns) %}
  {% if strategy == 'merge' %}
    {% do return(get_merge_sql(target_relation, tmp_relation, unique_key, dest_columns)) %}
  {% elif strategy == 'delete+insert' %}
    {% do return(get_delete_insert_merge_sql(target_relation, tmp_relation, unique_key, dest_columns)) %}
  {% else %}
    {% do exceptions.raise_compiler_error('invalid strategy: ' ~ strategy) %}
  {% endif %}
{% endmacro %}
 
{% macro incremental_validate_on_schema_change(on_schema_change, default_value='ignore') %}
   
   {% if on_schema_change not in ['sync', 'append', 'fail', 'ignore'] %}
     {{ return(default_value) }}
 
   {% else %}
     {{ return(on_schema_change) }}
   
   {% endif %}
 
{% endmacro %}
 
{% macro diff_columns(array_one, array_two) %}
 
  {% set array_one_name = [] %}
  {% set array_two_name = [] %}
 
  {%- for col in array_one -%}
    {{ array_one_name.append(col.column) }}
  {%- endfor -%}
 
  {%- for col in array_two -%}
    {{ array_two_name.append(col.column) }}
  {%- endfor -%}
 
  {{ log("array_one_name - " ~ array_one_name ) }}
  {{ log("array_two_name - " ~ array_two_name ) }}
 
  {% set result = [] %}
   {%- for col in array_one -%}
      {%- if col.column not in array_two_name -%} 
      {{ result.append(col) }}
      {%- endif -%}
   {%- endfor -%}
 
   {{ log("result - " ~ result ) }}
   {{ return(result) }}
 
{% endmacro %}
 
{% macro check_for_schema_changes(source_relation, target_relation) %}
  
  {% set schema_changed = False %}
  {%- set source_columns = adapter.get_columns_in_relation(source_relation) -%}
  {%- set target_columns = adapter.get_columns_in_relation(target_relation) -%}
 
  {% if source_columns != target_columns %}
    {% set schema_changed = True %}
  {% endif %}
 
  {{return(schema_changed)}}
 
{% endmacro %}
 
{% macro sync_columns(source_relation, target_relation, on_schema_change='append') %}
  
  {%- set source_columns = adapter.get_columns_in_relation(source_relation) -%}
  {%- set target_columns = adapter.get_columns_in_relation(target_relation) -%}
  {%- set add_to_target_arr = diff_columns(source_columns, target_columns) -%}
  {%- set remove_from_target_arr = diff_columns(target_columns, source_columns) -%}
 
  {%- if on_schema_change == 'append' -%}
    {%- for col in add_to_target_arr -%}
       {%- set build_sql = 'ALTER TABLE ' + target_relation.database+'.'+target_relation.schema+'.'+target_relation.name + ' ADD COLUMN ' + col.name + ' ' + col.dtype -%}
       {%- do run_query(build_sql) -%}
    {%- endfor -%}
    
  {% elif on_schema_change == 'sync' %}
    {%- for col in add_to_target_arr -%}
       {%- set build_sql = 'ALTER TABLE ' + target_relation.database+'.'+target_relation.schema+'.'+target_relation.name + ' ADD COLUMN ' + col.name + ' ' + col.dtype -%}
       {%- do run_query(build_sql) -%}
    {%- endfor -%}
 
    {%- for col in remove_from_target_arr -%}
      {%- set build_sql = 'ALTER TABLE ' + target_relation.database+'.'+target_relation.schema+'.'+target_relation.name + ' DROP COLUMN ' + col.name -%}
      {%- do run_query(build_sql) -%}
    {%- endfor -%}
  
  {% endif %}
 
  {{ 
      return(
             {
              'columns_added': add_to_target_arr,
              'columns_removed': remove_from_target_arr
             }
          )
  }}
  
{% endmacro %}
 
{% materialization incremental_custom, adapter='snowflake' -%}
 
  {% set original_query_tag = set_query_tag() %}
 
  {%- set unique_key = config.get('unique_key') -%}
  {%- set on_schema_change = incremental_validate_on_schema_change(config.get('on_schema_change')) -%}
 
  {%- set full_refresh_mode = (should_full_refresh()) -%}
 
  {% set target_relation = this %}
  {% set existing_relation = load_relation(this) %}
  {% set tmp_relation = make_temp_relation(this) %}
 
  {#-- Validate early so we don't run SQL if the strategy is invalid --#}
  {% set strategy = dbt_snowflake_validate_get_incremental_strategy(config) -%}
 
  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}
 
  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}
 
  {% if existing_relation is none %}
    {% set build_sql = create_table_as(False, target_relation, sql) %}
  {% elif existing_relation.is_view %}
    {#-- Can't overwrite a view with a table - we must drop --#}
    {{ log("Dropping relation " ~ target_relation ~ " because it is a view and this model is a table.") }}
    {% do adapter.drop_relation(existing_relation) %}
    {% set build_sql = create_table_as(False, target_relation, sql) %}
  {% elif full_refresh_mode %}
    {% set build_sql = create_table_as(False, target_relation, sql) %}
  {% else %}
    {% do run_query(create_table_as(True, tmp_relation, sql)) %}
 
    {% set schema_changed = check_for_schema_changes(tmp_relation, target_relation) %}
 
    {% if schema_changed %}
      
      {% if on_schema_change=='fail' %}
        {{ 
          exceptions.raise_compiler_error('The source and target schemas on this incremental model are out of sync!
               Please re-run the incremental model with full_refresh set to True to update the target schema.
               Alternatively, you can update the schema manually and re-run the process.') 
        }}
      
      {# unless we ignore, run the sync operation per the config #}
      {% elif on_schema_change != 'ignore' %}
        
        {% set schema_changes = sync_columns(tmp_relation, target_relation, on_schema_change) %}
 
      {% endif %}
 
    {% endif %}
 
    {% do adapter.expand_target_column_types(
           from_relation=tmp_relation,
           to_relation=target_relation) %}
    
    {% set dest_columns = adapter.get_columns_in_relation(target_relation) %}
    {{ log("target_relation - " ~ target_relation ) }}
    {{ log("dest_columns - " ~ dest_columns ) }}
    {% set build_sql = dbt_snowflake_get_incremental_sql(strategy, tmp_relation, target_relation, unique_key, dest_columns) %}
  
  
  {% endif %}
 
  {%- call statement('main') -%}
    {{ build_sql }}
  {%- endcall -%}
 
  {{ run_hooks(post_hooks, inside_transaction=True) }}
 
  -- `COMMIT` happens here
  {{ adapter.commit() }}
 
  {{ run_hooks(post_hooks, inside_transaction=False) }}
 
  {% set target_relation = target_relation.incorporate(type='table') %}
  {% do persist_docs(target_relation, model) %}
 
  {% do unset_query_tag(original_query_tag) %}
 
  {{ return({'relations': [target_relation]}) }}
 
{%- endmaterialization %}