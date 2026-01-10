SELECT
    *
FROM {{ source('raw_covid', 'smoking') }}