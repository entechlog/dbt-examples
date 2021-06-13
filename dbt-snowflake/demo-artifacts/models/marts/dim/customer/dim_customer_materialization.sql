{{
    config(materialized='persistent_table'
        ,retain_previous_version_flg=false
        ,migrate_data_over_flg=false
    )
}}

CREATE OR REPLACE TABLE "{{ database }}"."{{ schema }}"."dim_customer_materialization" (
    CUSTOMER_ID NUMBER(38,0),
	CUSTOMER_FIRST_NAME VARCHAR(100),
	CUSTOMER_LAST_NAME VARCHAR(100),
	CUSTOMER_EMAIL VARCHAR(100)
)

--AS SELECT
--CUSTOMER_ID,
--CUSTOMER_FIRST_NAME,
--CUSTOMER_LAST_NAME,
--CUSTOMER_EMAIL
--FROM {{ ref('stg_customer') }}