with source as (

    select * from {{ source('covid', 'median-age-and-life-expectancy') }}

),

renamed as (

    select
        -- TODO: add specific column selection here
        *

    from source

)

select * from renamed
