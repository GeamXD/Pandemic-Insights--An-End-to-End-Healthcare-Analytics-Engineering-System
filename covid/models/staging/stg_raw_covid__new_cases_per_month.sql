SELECT
    *
FROM {{ source('raw_covid', 'new_cases_per_month') }}