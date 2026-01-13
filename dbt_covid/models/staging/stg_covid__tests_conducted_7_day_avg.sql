with source as (

    select * from {{ source('covid', 'tests-conducted-7-day-avg') }}

),

renamed as (

    select
        -- TODO: add specific column selection here
        *

    from source

)

select * from renamed
