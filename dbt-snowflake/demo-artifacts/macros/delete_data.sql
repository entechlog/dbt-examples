{% macro delete_data(del_key, del_value, database, schema, table) %}
 
{%- set relation = adapter.get_relation(this.database, this.schema, this.table) -%}
 
{%- if relation is not none -%}
    {%- call statement('delete ' ~ del_value ~ ' records from ' ~ table, fetch_result=False, auto_begin=True) -%}
    delete from {{ this }} where {{del_key}} = '{{del_value}}'
    {%- endcall -%}
{%- endif -%}
 
{% endmacro %}