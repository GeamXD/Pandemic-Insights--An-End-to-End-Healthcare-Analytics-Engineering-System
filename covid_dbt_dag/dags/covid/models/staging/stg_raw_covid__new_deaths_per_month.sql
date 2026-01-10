SELECT
    *
FROM {{ source('raw_covid', 'new_deaths_per_month') }}