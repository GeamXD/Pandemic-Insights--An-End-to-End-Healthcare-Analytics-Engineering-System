with source as (

    select * from {{ source('covid', 'vaccine-administered') }}

),

renamed as (

    select
        -- TODO: add specific column selection here
        string_field_0 as Geography,
        string_field_1 as Indicator,
        string_field_2 as Count

    from source

)

select * from renamed
