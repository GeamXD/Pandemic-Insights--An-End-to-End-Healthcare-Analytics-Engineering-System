SELECT
        TRIM(geography) as code,
        TRIM(gender) as gender,
        COALESCE(CAST(NULLIF(smoking_count, 'Null') AS FLOAT), 0) as smoking_count
FROM {{ ref('brz__smoking') }}