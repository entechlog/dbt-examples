{{
    config(materialized='persistent_table'
        ,retain_previous_version_flg=false
        ,migrate_data_over_flg=true
    )
}}

CREATE OR REPLACE TABLE "{{ database }}"."{{ schema }}"."dim_customer_cust" (
    CUSTOMER_ID NUMBER(38,0),
	CUSTOMER_FIRST_NAME VARCHAR(100),
	CUSTOMER_LAST_NAME VARCHAR(100),
	CUSTOMER_EMAIL VARCHAR(100)
)