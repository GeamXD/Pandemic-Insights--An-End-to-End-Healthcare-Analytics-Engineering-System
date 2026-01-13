with source as (

    select * from {{ source('covid', 'stringency-index') }}

),

renamed as (

    select
        -- TODO: add specific column selection here
        *

    from source

)

select * from renamed
