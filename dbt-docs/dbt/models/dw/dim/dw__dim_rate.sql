{{ config(alias="rate", materialized="table", transient=false, tags=["dw", "dim"]) }}

select rate_id, rate_code, rate_name
from {{ ref("stg__dim_rate") }}
