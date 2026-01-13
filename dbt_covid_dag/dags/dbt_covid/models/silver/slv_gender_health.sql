SELECT
        TRIM(geography) as code,
        TRIM(gender) as gender,
        COALESCE(SAFE_CAST(NULLIF(smoking_count, 'Null') AS FLOAT64), 0) as smoking_count
FROM {{ ref('brz__smoking') }}