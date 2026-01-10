SELECT
  code AS country_key,
  CAST(date_format(date, 'yyyyMM') AS INT) AS date_key,  -- Match dim_date_monthly
  new_cases_per_month_count,
  new_deaths_per_month_count
FROM {{ ref('slv_covid_monthly') }}