{% snapshot snap_customer %}

{{
    config(
      unique_key='customer_id',

      strategy='timestamp',
      updated_at='last_update',
      invalidate_hard_deletes=True,
    )
}}

select * from {{ ref('dim_customer_table') }}

{% endsnapshot %}
