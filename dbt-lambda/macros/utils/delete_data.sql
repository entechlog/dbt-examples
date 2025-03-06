{% macro delete_data(del_key, del_value, this, offset_days=0) %}

{%- set relation = adapter.get_relation(this.database, this.schema, this.table) -%}

{%- if relation is not none -%}
	{%- if var("run_type") == 'full-refresh'-%}
			{%- call statement('truncate table ' ~ this, fetch_result=False, auto_begin=True) -%}
				truncate {{ relation }}
			{%- endcall -%}
	{%- elif var("run_type") == 'daily'-%}	
		{% if offset_days != 0 %}
			{%- set sub_days = offset_days | default(0) -%}
			{%- set del_value_datetime = modules.datetime.datetime.strptime(del_value, "%Y%m%d") + modules.datetime.timedelta(days=sub_days) -%}
			{%- set del_value_date = del_value_datetime.strftime("'%Y%m%d'") -%}
			{%- call statement('delete ' ~ del_value_date ~ ' records from ' ~ this, fetch_result=False, auto_begin=True) -%}
				delete from {{ relation }} where {{del_key}} = {{del_value_date}}
			{%- endcall -%}
		{% else %}
			{%- call statement('delete ' ~ del_value ~ ' records from ' ~ this, fetch_result=False, auto_begin=True) -%}
				delete from {{ relation }} where {{del_key}} = '{{del_value}}'
			{%- endcall -%}
		{% endif %}
	{%- elif var("run_type") == 'backfill'-%}
		{% if offset_days > 0 %}
			{%- set sub_days = offset_days | default(0) -%}
			{%- set backfill_start_datetime = modules.datetime.datetime.strptime( var("backfill_start_date") , "%Y-%m-%d") + modules.datetime.timedelta(days=sub_days) -%}
			{%- set backfill_end_datetime = modules.datetime.datetime.strptime(var("backfill_end_date") , "%Y-%m-%d") + modules.datetime.timedelta(days=sub_days) -%}
			{%- set backfill_start_date = backfill_start_datetime.strftime("'%Y%m%d'") -%} 
			{%- set backfill_end_date = backfill_end_datetime.strftime("'%Y%m%d'") -%} 
			{%- call statement('delete ' ~ del_value ~ ' records from ' ~ this ~ ' where '~del_key~ ' between ' ~ backfill_start_date ~ ' and ' ~ backfill_end_date, fetch_result=False, auto_begin=True) -%}
				delete from {{ relation }} where {{del_key}} between {{backfill_start_date}} and {{backfill_end_date}}
			{%- endcall -%}
		{% else %}
			{%- call statement('delete ' ~ del_value ~ ' records from ' ~ this ~ ' where '~del_key~ ' between ' ~ var("backfill_start_date") ~ ' and ' ~ var("backfill_end_date"), fetch_result=False, auto_begin=True) -%}
				delete from {{ relation }} where {{ del_key }} between '{{ var("backfill_start_date") | replace('-', '') }}' and '{{ var("backfill_end_date") | replace('-', '') }}'
			{%- endcall -%}
		{% endif %}
	{% endif %}
{%- endif -%}

{% endmacro %}