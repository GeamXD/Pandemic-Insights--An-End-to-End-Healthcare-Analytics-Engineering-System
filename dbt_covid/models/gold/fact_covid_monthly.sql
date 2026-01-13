SELECT
  code AS country_key,
  -- FIX: Removed the hyphen so it becomes 202001 instead of 2020-01
  CAST(FORMAT_DATE('%Y%m', date ) AS INT64) AS date_key,
  new_cases_per_month_count,
  new_deaths_per_month_count
FROM {{ ref('slv_covid_monthly') }}