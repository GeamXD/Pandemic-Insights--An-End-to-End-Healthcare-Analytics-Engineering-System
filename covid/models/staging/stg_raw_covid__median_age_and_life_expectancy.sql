SELECT
    *
FROM {{ source('raw_covid', 'median_age_and_life_expectancy') }}