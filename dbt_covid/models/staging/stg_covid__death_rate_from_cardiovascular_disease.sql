with source as (

    select * from {{ source('covid', 'death-rate-from-cardiovascular-disease') }}

),

renamed as (

    select
        -- TODO: add specific column selection here
        *

    from source

)

select * from renamed
