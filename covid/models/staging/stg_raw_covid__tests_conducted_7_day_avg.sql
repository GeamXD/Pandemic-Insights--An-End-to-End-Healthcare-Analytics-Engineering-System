SELECT
    *
FROM {{ source('raw_covid', 'tests_conducted_7_day_avg') }}