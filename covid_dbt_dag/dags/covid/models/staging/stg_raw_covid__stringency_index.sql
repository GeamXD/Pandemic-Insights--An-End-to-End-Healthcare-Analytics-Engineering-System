SELECT
    *
FROM {{ source('raw_covid', 'stringency_index') }}