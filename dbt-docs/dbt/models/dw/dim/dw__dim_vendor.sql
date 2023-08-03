{{
    config(
        alias="dim_vendor", materialized="table", transient=false, tags=["dw", "dim"]
    )
}}

select vendor_id, vendor_code, vendor_name
from {{ ref("stg__dim_vendor") }}
