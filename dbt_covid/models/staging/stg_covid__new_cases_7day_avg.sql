with source as (

    select * from {{ source('covid', 'new-cases-7day-avg') }}

),

renamed as (

    select
        -- TODO: add specific column selection here
        *

    from source

)

select * from renamed
