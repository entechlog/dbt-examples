{{
    config(
        alias="location", materialized="table", transient=false, tags=["dw", "dim"]
    )
}}

select location_id, latitude, longitude
from {{ ref("stg__dim_location") }}
