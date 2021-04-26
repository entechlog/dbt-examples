{% macro grant_select_on_schemas(database_schemas, role) %}

-- Log incoming variables
{{ log("List of schemas : " ~ database_schemas ) }}
{{ log("Role name       : " ~ role ) }}

{% for (database, schema) in database_schemas %}

  -- Log current database and schema details
  {{ log("Now processing  : " ~ database ~ "." ~ schema ) }}
  {% if target.name == 'dev' %}

    grant usage on schema {{ database }}.{{ schema }} to role {{ role }};
    grant select on all tables in schema {{ database }}.{{ schema }} to role {{ role }};
    grant select on all views in schema {{ database }}.{{ schema }} to role {{ role }};
  {% elif target.name == 'prod' %}
    select 1;
  {% else %}
    select 1; -- hooks will error if they don't have valid SQL in them, this handles that!
  {% endif %}

{% endfor %}

{% endmacro %}