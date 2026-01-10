SELECT
    *
FROM {{ source('raw_covid', 'human_development_index') }}