SELECT
    *
FROM {{ source('raw_covid', 'new_cases_7day_avg') }}