SELECT
  code AS country_key,
  date AS date_key,  -- Keep as date (daily grain)
  new_cases_7day_avg,
  new_deaths_7_day_avg,
  stringency_index,
  test_count
  -- ADD vaccination if available at daily level
  -- least_1_vaccine_dose,
  -- all_vaccine_doses
FROM {{ ref('slv_covid_daily') }}