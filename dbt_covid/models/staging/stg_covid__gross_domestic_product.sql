with source as (

    select * from {{ source('covid', 'gross-domestic-product') }}

),

renamed as (

    select
        -- TODO: add specific column selection here
        *

    from source

)

select * from renamed
