# SQL Query Examples

This document provides practical SQL query examples for analyzing COVID-19 data in the Pandemic Insights system. All queries assume you're connected to the PostgreSQL database with access to the `gold` schema.

## Table of Contents

- [Basic Queries](#basic-queries)
- [Time Series Analysis](#time-series-analysis)
- [Country Comparisons](#country-comparisons)
- [Aggregations and Trends](#aggregations-and-trends)
- [Advanced Analytics](#advanced-analytics)
- [Machine Learning Preparation](#machine-learning-preparation)
- [Performance Queries](#performance-queries)

## Basic Queries

### List All Countries
```sql
SELECT 
    country_code,
    country_name,
    population,
    hum_dev_index
FROM gold.dim_country
ORDER BY country_name;
```

### Get Latest Daily Metrics for a Country
```sql
SELECT 
    d.date_key,
    c.country_name,
    f.new_cases_7day_avg,
    f.new_deaths_7_day_avg,
    f.stringency_index,
    f.test_count
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
JOIN gold.dim_date d ON f.date_key = d.date_key
WHERE c.country_code = 'USA'
ORDER BY d.date_key DESC
LIMIT 30;
```

### Total Cases and Deaths by Country
```sql
SELECT 
    c.country_name,
    SUM(f.new_cases_7day_avg) as total_cases,
    SUM(f.new_deaths_7_day_avg) as total_deaths,
    ROUND(
        (SUM(f.new_deaths_7_day_avg) / NULLIF(SUM(f.new_cases_7day_avg), 0)) * 100, 
        2
    ) as case_fatality_rate
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
WHERE f.date_key >= '2020-01-01'
GROUP BY c.country_name
HAVING SUM(f.new_cases_7day_avg) > 1000
ORDER BY total_cases DESC
LIMIT 20;
```

## Time Series Analysis

### Daily Cases Trend for Multiple Countries
```sql
SELECT 
    d.date_key,
    c.country_code,
    c.country_name,
    f.new_cases_7day_avg,
    f.new_deaths_7_day_avg
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
JOIN gold.dim_date d ON f.date_key = d.date_key
WHERE c.country_code IN ('USA', 'GBR', 'FRA', 'DEU', 'ITA')
    AND d.date_key >= '2021-01-01'
ORDER BY d.date_key, c.country_name;
```

### Weekly Aggregation
```sql
SELECT 
    c.country_name,
    DATE_TRUNC('week', d.date_key) as week_start,
    AVG(f.new_cases_7day_avg) as avg_weekly_cases,
    AVG(f.new_deaths_7_day_avg) as avg_weekly_deaths,
    AVG(f.stringency_index) as avg_stringency
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
JOIN gold.dim_date d ON f.date_key = d.date_key
WHERE c.country_code = 'USA'
    AND d.date_key >= '2021-01-01'
GROUP BY c.country_name, DATE_TRUNC('week', d.date_key)
ORDER BY week_start;
```

### Month-over-Month Growth Rate
```sql
WITH monthly_data AS (
    SELECT 
        c.country_name,
        DATE_TRUNC('month', f.date_key) as month,
        SUM(f.new_cases_7day_avg) as total_cases
    FROM gold.fact_covid_daily f
    JOIN gold.dim_country c ON f.country_key = c.country_key
    WHERE c.country_code = 'USA'
    GROUP BY c.country_name, DATE_TRUNC('month', f.date_key)
)
SELECT 
    country_name,
    month,
    total_cases,
    LAG(total_cases) OVER (ORDER BY month) as prev_month_cases,
    ROUND(
        ((total_cases - LAG(total_cases) OVER (ORDER BY month)) 
        / NULLIF(LAG(total_cases) OVER (ORDER BY month), 0)) * 100,
        2
    ) as growth_rate_pct
FROM monthly_data
ORDER BY month DESC;
```

### Peak Detection
```sql
WITH daily_ranks AS (
    SELECT 
        c.country_name,
        d.date_key,
        f.new_cases_7day_avg,
        RANK() OVER (PARTITION BY c.country_key ORDER BY f.new_cases_7day_avg DESC) as rank
    FROM gold.fact_covid_daily f
    JOIN gold.dim_country c ON f.country_key = c.country_key
    JOIN gold.dim_date d ON f.date_key = d.date_key
    WHERE f.new_cases_7day_avg IS NOT NULL
)
SELECT 
    country_name,
    date_key as peak_date,
    new_cases_7day_avg as peak_cases
FROM daily_ranks
WHERE rank = 1
ORDER BY peak_cases DESC
LIMIT 20;
```

## Country Comparisons

### Countries by HDI Category
```sql
SELECT 
    CASE 
        WHEN c.hum_dev_index >= 0.8 THEN 'Very High'
        WHEN c.hum_dev_index >= 0.7 THEN 'High'
        WHEN c.hum_dev_index >= 0.55 THEN 'Medium'
        ELSE 'Low'
    END as hdi_category,
    COUNT(DISTINCT c.country_key) as num_countries,
    AVG(c.population) as avg_population,
    AVG(c.gdp_per_capita) as avg_gdp,
    AVG(c.life_expectancy) as avg_life_expectancy
FROM gold.dim_country c
WHERE c.hum_dev_index IS NOT NULL
GROUP BY 
    CASE 
        WHEN c.hum_dev_index >= 0.8 THEN 'Very High'
        WHEN c.hum_dev_index >= 0.7 THEN 'High'
        WHEN c.hum_dev_index >= 0.55 THEN 'Medium'
        ELSE 'Low'
    END
ORDER BY 
    CASE hdi_category
        WHEN 'Very High' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        ELSE 4
    END;
```

### Healthcare Capacity vs COVID Impact
```sql
SELECT 
    c.country_name,
    c.pct_hos_beds as hospital_beds_per_1000,
    c.population,
    SUM(f.new_cases_7day_avg) as total_cases,
    SUM(f.new_deaths_7_day_avg) as total_deaths,
    ROUND(
        SUM(f.new_deaths_7_day_avg) / (c.population / 100000),
        2
    ) as deaths_per_100k
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
WHERE c.pct_hos_beds IS NOT NULL
GROUP BY c.country_name, c.pct_hos_beds, c.population
HAVING SUM(f.new_cases_7day_avg) > 10000
ORDER BY c.pct_hos_beds DESC
LIMIT 20;
```

### High-Risk Population Analysis
```sql
SELECT 
    c.country_name,
    c.pct_70_plus as pct_age_70_plus,
    c.pct_diabetes,
    c.cvd_death_rate,
    AVG(f.new_deaths_7_day_avg) as avg_daily_deaths,
    COUNT(DISTINCT f.date_key) as days_reported
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
WHERE c.pct_70_plus IS NOT NULL
    AND f.date_key >= '2021-01-01'
GROUP BY 
    c.country_name,
    c.pct_70_plus,
    c.pct_diabetes,
    c.cvd_death_rate
HAVING COUNT(DISTINCT f.date_key) > 100
ORDER BY c.pct_70_plus DESC
LIMIT 15;
```

## Aggregations and Trends

### Monthly Summary Statistics
```sql
SELECT 
    d.year,
    d.month,
    d.month_name,
    COUNT(DISTINCT f.country_key) as countries_reporting,
    SUM(f.new_cases_7day_avg) as total_cases,
    SUM(f.new_deaths_7_day_avg) as total_deaths,
    AVG(f.stringency_index) as avg_stringency,
    AVG(f.test_count) as avg_daily_tests
FROM gold.fact_covid_daily f
JOIN gold.dim_date d ON f.date_key = d.date_key
WHERE d.year >= 2020
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
```

### Stringency Index vs Cases Correlation
```sql
WITH country_metrics AS (
    SELECT 
        c.country_name,
        AVG(f.stringency_index) as avg_stringency,
        SUM(f.new_cases_7day_avg) / c.population * 100000 as cases_per_100k
    FROM gold.fact_covid_daily f
    JOIN gold.dim_country c ON f.country_key = c.country_key
    WHERE f.date_key >= '2020-06-01'
        AND f.stringency_index IS NOT NULL
    GROUP BY c.country_name, c.population
    HAVING SUM(f.new_cases_7day_avg) > 1000
)
SELECT 
    CASE 
        WHEN avg_stringency >= 75 THEN 'Very Strict (75+)'
        WHEN avg_stringency >= 50 THEN 'Strict (50-75)'
        WHEN avg_stringency >= 25 THEN 'Moderate (25-50)'
        ELSE 'Lenient (0-25)'
    END as stringency_category,
    COUNT(*) as num_countries,
    ROUND(AVG(cases_per_100k), 2) as avg_cases_per_100k,
    ROUND(MIN(cases_per_100k), 2) as min_cases_per_100k,
    ROUND(MAX(cases_per_100k), 2) as max_cases_per_100k
FROM country_metrics
GROUP BY 
    CASE 
        WHEN avg_stringency >= 75 THEN 'Very Strict (75+)'
        WHEN avg_stringency >= 50 THEN 'Strict (50-75)'
        WHEN avg_stringency >= 25 THEN 'Moderate (25-50)'
        ELSE 'Lenient (0-25)'
    END
ORDER BY AVG(cases_per_100k);
```

### Weekend vs Weekday Patterns
```sql
SELECT 
    c.country_name,
    d.is_weekend,
    CASE WHEN d.is_weekend THEN 'Weekend' ELSE 'Weekday' END as day_type,
    COUNT(*) as num_days,
    AVG(f.new_cases_7day_avg) as avg_cases,
    AVG(f.test_count) as avg_tests
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
JOIN gold.dim_date d ON f.date_key = d.date_key
WHERE c.country_code IN ('USA', 'GBR', 'FRA')
    AND d.date_key >= '2021-01-01'
GROUP BY c.country_name, d.is_weekend
ORDER BY c.country_name, d.is_weekend;
```

## Advanced Analytics

### Rolling Averages
```sql
SELECT 
    c.country_name,
    d.date_key,
    f.new_cases_7day_avg as cases,
    AVG(f.new_cases_7day_avg) OVER (
        PARTITION BY c.country_key 
        ORDER BY d.date_key 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) as cases_30_day_avg,
    AVG(f.new_cases_7day_avg) OVER (
        PARTITION BY c.country_key 
        ORDER BY d.date_key 
        ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
    ) as cases_90_day_avg
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
JOIN gold.dim_date d ON f.date_key = d.date_key
WHERE c.country_code = 'USA'
    AND d.date_key >= '2021-01-01'
ORDER BY d.date_key DESC
LIMIT 90;
```

### Percentile Analysis
```sql
WITH country_stats AS (
    SELECT 
        c.country_name,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f.new_cases_7day_avg) as median_cases,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY f.new_cases_7day_avg) as p75_cases,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY f.new_cases_7day_avg) as p95_cases,
        MAX(f.new_cases_7day_avg) as max_cases
    FROM gold.fact_covid_daily f
    JOIN gold.dim_country c ON f.country_key = c.country_key
    WHERE f.date_key >= '2020-01-01'
    GROUP BY c.country_name
)
SELECT 
    country_name,
    ROUND(median_cases, 2) as median_daily_cases,
    ROUND(p75_cases, 2) as p75_daily_cases,
    ROUND(p95_cases, 2) as p95_daily_cases,
    ROUND(max_cases, 2) as max_daily_cases
FROM country_stats
WHERE max_cases > 1000
ORDER BY max_cases DESC
LIMIT 20;
```

### Cohort Analysis by HDI
```sql
SELECT 
    CASE 
        WHEN c.hum_dev_index >= 0.8 THEN 'Very High HDI'
        WHEN c.hum_dev_index >= 0.7 THEN 'High HDI'
        ELSE 'Medium/Low HDI'
    END as hdi_group,
    d.month_name,
    COUNT(DISTINCT c.country_key) as num_countries,
    AVG(f.new_cases_7day_avg) as avg_cases,
    AVG(f.new_deaths_7_day_avg) as avg_deaths,
    AVG(f.test_count) as avg_tests
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
JOIN gold.dim_date d ON f.date_key = d.date_key
WHERE d.year = 2021
    AND c.hum_dev_index IS NOT NULL
GROUP BY 
    CASE 
        WHEN c.hum_dev_index >= 0.8 THEN 'Very High HDI'
        WHEN c.hum_dev_index >= 0.7 THEN 'High HDI'
        ELSE 'Medium/Low HDI'
    END,
    d.month,
    d.month_name
ORDER BY d.month, hdi_group;
```

## Machine Learning Preparation

### Extract ML Features with Targets
```sql
SELECT 
    ml.country_key,
    c.country_code,
    ml.date_key,
    ml.target_cases,
    ml.target_deaths,
    ml.cases_lag_7d,
    ml.deaths_lag_14d,
    ml.stringency_index,
    ml.stringency_lag_14d,
    ml.test_count,
    ml.pct_70_plus,
    ml.pct_diabetes,
    ml.pct_hos_beds,
    ml.hum_dev_index,
    ml.population_density_2020,
    ml.case_fatality_rate
FROM gold.ml_features ml
JOIN gold.dim_country c ON ml.country_key = c.country_key
WHERE ml.cases_lag_7d IS NOT NULL
    AND ml.deaths_lag_14d IS NOT NULL
    AND ml.date_key >= '2021-01-01'
ORDER BY ml.date_key, ml.country_key;
```

### Training/Test Split by Date
```sql
-- Training set (80% of data)
SELECT *
FROM gold.ml_features
WHERE date_key < '2023-01-01'
    AND cases_lag_7d IS NOT NULL;

-- Test set (20% of data)
SELECT *
FROM gold.ml_features
WHERE date_key >= '2023-01-01'
    AND cases_lag_7d IS NOT NULL;
```

### Feature Correlation Analysis
```sql
SELECT 
    CORR(ml.stringency_index, ml.target_cases) as stringency_cases_corr,
    CORR(ml.test_count, ml.target_cases) as tests_cases_corr,
    CORR(ml.cases_lag_7d, ml.target_cases) as lag_cases_corr,
    CORR(ml.pct_70_plus, ml.case_fatality_rate) as age_cfr_corr,
    CORR(ml.pct_hos_beds, ml.case_fatality_rate) as beds_cfr_corr
FROM gold.ml_features ml
WHERE ml.date_key >= '2021-01-01'
    AND ml.cases_lag_7d IS NOT NULL;
```

## Performance Queries

### Countries with Most Complete Data
```sql
SELECT 
    c.country_name,
    COUNT(DISTINCT f.date_key) as days_with_data,
    MIN(f.date_key) as first_date,
    MAX(f.date_key) as last_date,
    COUNT(*) FILTER (WHERE f.new_cases_7day_avg IS NOT NULL) as days_with_cases,
    COUNT(*) FILTER (WHERE f.new_deaths_7_day_avg IS NOT NULL) as days_with_deaths,
    COUNT(*) FILTER (WHERE f.test_count IS NOT NULL) as days_with_tests
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
GROUP BY c.country_name
HAVING COUNT(DISTINCT f.date_key) > 365
ORDER BY days_with_data DESC
LIMIT 20;
```

### Data Quality Check
```sql
SELECT 
    'fact_covid_daily' as table_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT country_key) as unique_countries,
    COUNT(DISTINCT date_key) as unique_dates,
    COUNT(*) FILTER (WHERE new_cases_7day_avg IS NULL) as null_cases,
    COUNT(*) FILTER (WHERE new_deaths_7_day_avg IS NULL) as null_deaths,
    COUNT(*) FILTER (WHERE stringency_index IS NULL) as null_stringency
FROM gold.fact_covid_daily;
```

### Latest Data Availability
```sql
SELECT 
    c.country_name,
    MAX(f.date_key) as latest_date,
    CURRENT_DATE - MAX(f.date_key) as days_since_update,
    MAX(f.new_cases_7day_avg) as latest_cases
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
GROUP BY c.country_name
ORDER BY MAX(f.date_key) DESC
LIMIT 20;
```

## Export Queries

### Export for Visualization Tools
```sql
-- Copy to CSV for external tools
COPY (
    SELECT 
        c.country_code,
        c.country_name,
        d.date_key,
        f.new_cases_7day_avg,
        f.new_deaths_7_day_avg,
        f.stringency_index
    FROM gold.fact_covid_daily f
    JOIN gold.dim_country c ON f.country_key = c.country_key
    JOIN gold.dim_date d ON f.date_key = d.date_key
    WHERE d.date_key >= '2021-01-01'
    ORDER BY d.date_key, c.country_code
) TO '/tmp/covid_export.csv' WITH CSV HEADER;
```

### Summary Report for Leadership
```sql
SELECT 
    d.year,
    d.quarter,
    COUNT(DISTINCT c.country_key) as countries_tracked,
    SUM(f.new_cases_7day_avg) as total_cases,
    SUM(f.new_deaths_7_day_avg) as total_deaths,
    ROUND(AVG(f.stringency_index), 2) as avg_stringency,
    ROUND(
        (SUM(f.new_deaths_7_day_avg) / NULLIF(SUM(f.new_cases_7day_avg), 0)) * 100,
        2
    ) as overall_cfr
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
JOIN gold.dim_date d ON f.date_key = d.date_key
WHERE d.year >= 2020
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;
```

## Tips for Query Performance

1. **Always filter by date** early in the query
2. **Use appropriate indexes** on join columns
3. **Limit result sets** with `LIMIT` for exploratory queries
4. **Use CTEs** for complex multi-step logic
5. **Aggregate before joining** when possible
6. **Monitor query plans** with `EXPLAIN ANALYZE`

## Additional Resources

- For model documentation: `dbt docs serve`
- For data lineage: View in dbt documentation
- For schema details: See [DATA_DICTIONARY.md](DATA_DICTIONARY.md)

---

**Have a query to contribute? Submit a PR!**
