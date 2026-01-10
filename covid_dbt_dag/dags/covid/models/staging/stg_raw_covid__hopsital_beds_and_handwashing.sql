SELECT
    *
FROM {{ source('raw_covid', 'hopsital_beds_and_handwashing') }}