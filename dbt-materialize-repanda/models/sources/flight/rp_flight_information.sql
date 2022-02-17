{{ config(
    materialized='source',
    tags = ["source","redpanda"]) 
}}

{% set source_name %}
    {{ mz_generate_name('rp_flight_information') }}
{% endset %}

CREATE SOURCE {{ source_name }}
FROM KAFKA BROKER {{ "'" ~ var('redpanda_broker') ~ "'" }}  TOPIC 'flight_information'
  KEY FORMAT BYTES
  VALUE FORMAT BYTES
ENVELOPE UPSERT;