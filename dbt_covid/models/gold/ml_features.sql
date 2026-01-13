SELECT
    d.country_key,
    d.date_key,
    
    -- Targets
    d.new_deaths_7_day_avg AS target_deaths,
    d.new_cases_7day_avg AS target_cases,
    
    -- Time series features
    LAG(d.new_cases_7day_avg, 7) OVER (PARTITION BY d.country_key ORDER BY d.date_key) AS cases_lag_7d,
    LAG(d.new_deaths_7_day_avg, 14) OVER (PARTITION BY d.country_key ORDER BY d.date_key) AS deaths_lag_14d,
    
    -- Policy features
    d.stringency_index,
    LAG(d.stringency_index, 14) OVER (PARTITION BY d.country_key ORDER BY d.date_key) AS stringency_lag_14d,
    
    -- Country characteristics
    c.pct_70_plus,
    c.pct_diabetes,
    c.pct_hos_beds,
    c.hum_dev_index,
    c.population_density_2020,
    
    -- Testing
    d.test_count,
    
    -- Calculated metrics
    (d.new_deaths_7_day_avg / NULLIF(d.new_cases_7day_avg, 0)) * 100 AS case_fatality_rate
    
FROM {{ ref('fact_covid_daily') }} d
JOIN {{ ref('dim_country') }} c ON d.country_key = c.country_key