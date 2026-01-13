SELECT DISTINCT
  code AS country_key,
  code,
  -- Demographics
  population_2020,
  population_density_2020,
  median_age,
  pct_70_plus,
  pct_under_70,
  -- Socioeconomic
  gdp,
  hum_dev_index,
  life_expectancy,
  -- Health Infrastructure (MOVED from dim_health_profile)
  death_rate_2017,
  pct_diabetes,
  pct_handwashing,
  pct_hos_beds
FROM {{ ref('slv_geo_health') }}