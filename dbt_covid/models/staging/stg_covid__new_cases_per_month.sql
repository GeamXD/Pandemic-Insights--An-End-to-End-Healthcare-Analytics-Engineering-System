with source as (

    select * from {{ source('covid', 'new-cases-per-month') }}

),

renamed as (

    select
        -- TODO: add specific column selection here
        *

    from source

)

select * from renamed
