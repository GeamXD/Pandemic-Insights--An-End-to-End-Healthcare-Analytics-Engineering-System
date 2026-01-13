with source as (

    select * from {{ source('covid', 'population') }}

),

renamed as (

    select
        -- TODO: add specific column selection here
        *

    from source

)

select * from renamed
