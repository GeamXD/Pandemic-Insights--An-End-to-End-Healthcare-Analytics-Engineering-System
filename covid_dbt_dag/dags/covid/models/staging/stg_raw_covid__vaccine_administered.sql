SELECT
    *
FROM {{ source('raw_covid', 'vaccine_administered') }}