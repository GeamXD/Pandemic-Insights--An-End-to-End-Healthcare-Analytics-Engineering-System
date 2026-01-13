SELECT
    DISTINCT gender AS gender_key,
    gender
FROM {{ ref('slv_gender_health') }}