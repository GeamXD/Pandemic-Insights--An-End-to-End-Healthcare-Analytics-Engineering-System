SELECT
    *
FROM {{ source('raw_covid', 'diabetes_prevalence') }}