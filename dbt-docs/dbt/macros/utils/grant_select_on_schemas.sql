{% macro grant_select_on_schemas(database_schemas, role) %}
    {% if execute %}
        -- Log incoming variables
        {{
            log(
                modules.datetime.datetime.now().strftime("%H:%M:%S")
                ~ " | macro grant_select_on_schemas started successfully",
                info=False,
            )
        }}
        {{
            log(
                modules.datetime.datetime.now().strftime("%H:%M:%S")
                ~ " | environment                           : "
                ~ target.name
                | trim,
                info=False,
            )
        }}
        {{
            log(
                modules.datetime.datetime.now().strftime("%H:%M:%S")
                ~ " | database & schemas                    : "
                ~ database_schemas
                | trim,
                info=False,
            )
        }}
        {{
            log(
                modules.datetime.datetime.now().strftime("%H:%M:%S")
                ~ " | role                                  : "
                ~ role
                | trim,
                info=False,
            )
        }}

        {% for (database, schema) in database_schemas %}

            -- Log current database and schema details
            {{
                log(
                    modules.datetime.datetime.now().strftime("%H:%M:%S")
                    ~ " | now processing                        : "
                    ~ database
                    ~ "."
                    ~ schema
                    | trim,
                    info=False,
                )
            }}

            {% if target.name == "dev" %}
                grant usage
                on database {{ database }}
                to role {{ role }}
                ;
                grant usage
                on schema {{ database }}.{{ schema }}
                to role {{ role }}
                ;
                grant select
                on all tables in schema {{ database }}.{{ schema }}
                to role {{ role }}
                ;
                grant select
                on all views in schema {{ database }}.{{ schema }}
                to role {{ role }}
                ;
            {% elif target.name == "prod" %}
                select 1
                ;
            {% else %}
                select 1  -- hooks will error if they don't have valid SQL in them, this handles that!
                ;
            {% endif %}

        {% endfor %}

        {{
            log(
                modules.datetime.datetime.now().strftime("%H:%M:%S")
                ~ " | macro grant_select_on_schemas completed successfully",
                info=False,
            )
        }}
    {% endif %}
{% endmacro %}
