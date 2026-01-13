with source as (

    select * from {{ source('covid', 'high-risk-age-groups') }}

),

renamed as (

    select
        -- TODO: add specific column selection here
        *

    from source

)

select * from renamed
