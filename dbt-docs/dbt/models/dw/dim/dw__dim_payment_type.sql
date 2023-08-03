{{
    config(
        alias="payment_type",
        materialized="table",
        transient=false,
        tags=["dw", "dim"],
    )
}}

select payment_type_id, payment_type_code, payment_type_name
from {{ ref("stg__dim_payment_type") }}
