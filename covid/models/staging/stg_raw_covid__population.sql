SELECT
    *
FROM {{ source('raw_covid', 'population') }}