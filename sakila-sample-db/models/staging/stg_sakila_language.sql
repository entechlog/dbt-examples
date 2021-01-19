with source as (

    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_sakila_language') }}

),

renamed as (

    select
        language_id as language_id,
        name as language_name,
        last_update

    from source

)

select * from renamed
