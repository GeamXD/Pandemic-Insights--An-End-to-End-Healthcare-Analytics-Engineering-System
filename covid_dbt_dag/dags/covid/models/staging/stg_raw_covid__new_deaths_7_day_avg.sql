SELECT
    *
FROM {{ source('raw_covid', 'new_deaths_7_day_avg') }}