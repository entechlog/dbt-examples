{{ config(
    materialized = 'source', 
    tags = ["source","kafka"]
) }}

{% set source_name %}
    {{ mz_generate_name('src_kafka__users') }}
{% endset %}

CREATE SOURCE {{ source_name }}
FROM KAFKA BROKER {{ "'" ~ var('kafka_broker') ~ "'" }} 
TOPIC 'users'
FORMAT AVRO 
USING CONFLUENT SCHEMA REGISTRY {{ "'" ~ var('kafka_schema_registry') ~ "'" }} 
INCLUDE TIMESTAMP as event_timestamp