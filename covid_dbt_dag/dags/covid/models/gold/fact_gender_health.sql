SELECT
  code AS country_key,
  gender AS gender_key,
  smoking_count
FROM {{ ref('slv_gender_health') }}