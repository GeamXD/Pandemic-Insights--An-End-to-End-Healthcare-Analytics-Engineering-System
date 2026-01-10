SELECT
  code AS country_key,
  '202112' AS date_key,  -- Assuming latest snapshot
  least_1_vaccine_dose,
  all_vaccine_doses
FROM {{ ref('slv_geo_health') }}