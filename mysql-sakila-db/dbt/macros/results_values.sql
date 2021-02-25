{% macro results_values(results) %}
  {% for res in results -%}
    {% if loop.index > 1 %},{% endif %}
    ('{{ res.node.alias }}', '{{ res.status }}', {{ res.execution_time }}, getdate())
  {% endfor %}
{% endmacro %}
