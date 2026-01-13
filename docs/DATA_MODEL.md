# Data Model Documentation

This document describes the data model, sources, transformations, and schema for the Pandemic Insights system.

## Data Sources

### Source Files (CSV)
All source data is stored in the `data/raw/` directory:

| File | Description | Granularity |
|------|-------------|-------------|
| `new-cases-7day-avg.csv` | 7-day rolling average of new COVID cases | Daily, by country |
| `new-deaths-7-day-avg.csv` | 7-day rolling average of new COVID deaths | Daily, by country |
| `new-cases-per-month.csv` | Monthly new COVID cases | Monthly, by country |
| `new-deaths-per-month.csv` | Monthly new COVID deaths | Monthly, by country |
| `tests-conducted-7-day-avg.csv` | COVID tests conducted (7-day avg) | Daily, by country |
| `vaccine-administered.csv` | Vaccine doses administered | By country |
| `stringency-index.csv` | Government response stringency index | Daily, by country |
| `population.csv` | Population statistics | By country |
| `median-age-and-life-expectancy.csv` | Age and life expectancy data | By country |
| `high-risk-age-groups.csv` | Percentage of population in high-risk age groups | By country |
| `diabetes-prevalence.csv` | Diabetes prevalence | By country |
| `death-rate-from-cardiovascular-disease.csv` | Cardiovascular disease death rates | By country |
| `gross-domestic-product.csv` | GDP per capita | By country |
| `human-development-index.csv` | HDI scores | By country |
| `hospital-beds-and-handwashing.csv` | Hospital beds per capita and handwashing facilities | By country |
| `smoking.csv` | Smoking prevalence | By country |

### Raw Database Schema

**Schema**: `raw_covid`

All raw tables follow a similar structure:
```sql
CREATE TABLE raw_covid.{table_name} (
    Geography VARCHAR(256),
    date VARCHAR(256),        -- For time-series data
    Indicator VARCHAR(256),   -- For data with indicators
    Count VARCHAR(256)
);
```

Note: Raw tables use VARCHAR for all columns to handle data quality issues during ingestion.

## Medallion Architecture

### Layer Overview

```
RAW DATA → STAGING → BRONZE → SILVER → GOLD
           (views)   (tables)  (tables)  (tables)
```

### Staging Layer

**Purpose**: Direct source references with no transformation  
**Materialization**: Views  
**Schema**: References `raw_covid` schema  
**Pattern**: `stg_raw_covid__*`

**Models**: All staging models are simple `SELECT * FROM {{ source() }}` statements.

Example:
```sql
-- stg_raw_covid__new_cases_7day_avg.sql
SELECT * FROM {{ source('raw_covid', 'new_cases_7day_avg') }}
```

**Source Configuration**: Defined in `covid/models/staging/raw_covid.yml` with data quality tests.

### Bronze Layer

**Purpose**: Type casting, column renaming, and timestamping  
**Materialization**: Tables  
**Schema**: `bronze`  
**Pattern**: `brz__*`

**Transformations**:
- Cast columns to appropriate types (VARCHAR → appropriate types)
- Rename columns to snake_case
- Add `read_timestamp` for data lineage
- Keep all raw data (no filtering)

Example:
```sql
-- brz__new_cases_7day_avg.sql
SELECT
    geography,
    date,
    indicator as new_cases_7day_avg_indicator,
    count as new_cases_7day_avg,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_raw_covid__new_cases_7day_avg') }}
```

### Silver Layer

**Purpose**: Cleaned, joined, and conformed business data  
**Materialization**: Tables  
**Schema**: `silver`  
**Pattern**: `slv_*`

**Models**:

#### 1. `slv_covid_daily`
Daily COVID metrics by country.

**Grain**: One row per country per date

**Columns**:
- `code`: Country code (trimmed, cleaned)
- `date`: Date (properly typed)
- `new_cases_7day_avg`: 7-day rolling average of cases
- `new_deaths_7_day_avg`: 7-day rolling average of deaths
- `stringency_index`: Government response stringency
- `test_count`: Number of tests conducted

**Logic**: Joins multiple bronze tables on country and date, handles nulls, cleans geography codes.

#### 2. `slv_covid_monthly`
Monthly COVID metrics by country.

**Grain**: One row per country per month

**Columns**:
- `code`: Country code
- `date`: Month (DATE type)
- `new_cases_per_month`: Total cases in month
- `new_deaths_per_month`: Total deaths in month

#### 3. `slv_geo_health`
Geographic and health indicators by country.

**Grain**: One row per country

**Columns**:
- `code`: Country code
- `pct_70_plus`: Percentage of population 70+
- `pct_diabetes`: Diabetes prevalence
- `pct_cardiovascular_disease`: Cardiovascular disease death rate
- `pct_hos_beds`: Hospital beds per capita
- `median_age`: Median age of population
- `life_expectancy`: Life expectancy
- `hum_dev_index`: Human development index
- `population_density_2020`: Population density
- `pct_handwashing_facilities`: Access to handwashing facilities
- `pct_smoking`: Smoking prevalence

**Logic**: Consolidates all health and demographic indicators from multiple bronze tables.

#### 4. `slv_gender_health`
Gender-specific health metrics.

**Grain**: One row per country per gender

**Columns**:
- `code`: Country code
- `gender`: Gender (Male/Female)
- Health metrics by gender

### Gold Layer

**Purpose**: Business-ready star schema (facts and dimensions) and ML features  
**Materialization**: Tables  
**Schema**: `gold`  
**Pattern**: `fact_*`, `dim_*`, `ml_*`

#### Dimension Tables

##### `dim_country`
Country dimension with all attributes.

**Primary Key**: `country_key` (surrogate key = country code)

**Columns**:
- `country_key`: Country code (business key)
- `country_name`: Country name
- `pct_70_plus`: Elderly population percentage
- `pct_diabetes`: Diabetes prevalence
- `pct_cardiovascular_disease`: CVD death rate
- `pct_hos_beds`: Hospital beds per capita
- `median_age`: Median age
- `life_expectancy`: Life expectancy
- `hum_dev_index`: HDI score
- `population_density_2020`: Population density
- `pct_handwashing_facilities`: Handwashing access
- `pct_smoking`: Smoking prevalence

**Source**: `slv_geo_health`

##### `dim_date`
Date dimension for time intelligence.

**Primary Key**: `date_key` (DATE)

**Columns**:
- `date_key`: Date (business key)
- `year`: Year
- `month`: Month number
- `month_name`: Month name
- `quarter`: Quarter
- `day_of_week`: Day of week number
- `day_of_week_name`: Day name
- `day_of_month`: Day of month
- `day_of_year`: Day of year
- `week_of_year`: ISO week number
- `is_weekend`: Weekend flag

**Source**: Generated from min/max dates in data

##### `dim_gender`
Gender dimension.

**Primary Key**: `gender_key` (surrogate key)

**Columns**:
- `gender_key`: Surrogate key (1, 2)
- `gender_code`: Code (M, F)
- `gender_name`: Name (Male, Female)

**Source**: Static values

#### Fact Tables

##### `fact_covid_daily`
Daily COVID metrics - main fact table.

**Grain**: One row per country per date

**Primary Keys**: 
- `country_key`: FK to dim_country
- `date_key`: FK to dim_date

**Measures**:
- `new_cases_7day_avg`: 7-day rolling average of cases
- `new_deaths_7_day_avg`: 7-day rolling average of deaths
- `stringency_index`: Policy stringency
- `test_count`: Tests conducted

**Source**: `slv_covid_daily`

##### `fact_covid_monthly`
Monthly COVID metrics.

**Grain**: One row per country per month

**Primary Keys**:
- `country_key`: FK to dim_country
- `month_key`: FK to dim_date

**Measures**:
- `new_cases_per_month`: Total cases
- `new_deaths_per_month`: Total deaths

**Source**: `slv_covid_monthly`

##### `fact_vaccination`
Vaccination facts.

**Grain**: One row per country

**Primary Keys**:
- `country_key`: FK to dim_country

**Measures**:
- `least_1_vaccine_dose`: At least one dose administered
- `all_vaccine_doses`: All required doses administered

**Source**: `slv_vaccine_data` (to be created)

##### `fact_gender_health`
Gender-specific health metrics.

**Grain**: One row per country per gender

**Primary Keys**:
- `country_key`: FK to dim_country
- `gender_key`: FK to dim_gender

**Measures**:
- Gender-specific health indicators

**Source**: `slv_gender_health`

#### ML Features Table

##### `ml_features`
Feature engineering for machine learning models.

**Purpose**: Pre-computed features for predictive modeling

**Grain**: One row per country per date

**Features**:

*Target Variables*:
- `target_deaths`: Deaths to predict
- `target_cases`: Cases to predict

*Time Series Features*:
- `cases_lag_7d`: Cases from 7 days ago
- `deaths_lag_14d`: Deaths from 14 days ago

*Policy Features*:
- `stringency_index`: Current stringency
- `stringency_lag_14d`: Stringency from 14 days ago

*Country Characteristics*:
- `pct_70_plus`: Elderly population
- `pct_diabetes`: Diabetes prevalence
- `pct_hos_beds`: Hospital capacity
- `hum_dev_index`: Development level
- `population_density_2020`: Density

*Testing*:
- `test_count`: Tests conducted

*Calculated Metrics*:
- `case_fatality_rate`: Deaths/Cases ratio

**Source**: Joins `fact_covid_daily` and `dim_country` with window functions

## Data Lineage

### Full Lineage Example (Cases Data)

```
data/raw/new-cases-7day-avg.csv
    ↓ (SQL COPY)
raw_covid.new_cases_7day_avg
    ↓ (dbt source)
stg_raw_covid__new_cases_7day_avg (view)
    ↓ (dbt ref)
brz__new_cases_7day_avg (table)
    ↓ (dbt ref)
slv_covid_daily (table)
    ↓ (dbt ref)
fact_covid_daily (table)
    ↓ (dbt ref)
ml_features (table)
```

## Data Quality

### Tests Implemented

**Source Tests** (in `raw_covid.yml`):
- `not_null` tests on key columns (Geography, date, Count)

**Model Tests** (can be added in schema.yml files):
- Uniqueness tests on primary keys
- Referential integrity tests
- Value range tests
- Custom data quality tests

### Data Cleaning Rules

1. **Geography/Country Codes**: Trimmed of whitespace
2. **Null Handling**: 
   - "Null" strings converted to actual NULL
   - COALESCE used for numeric fields (default to 0 where appropriate)
3. **Type Casting**: All fields cast to appropriate types in bronze layer
4. **Date Handling**: All dates cast to DATE type
5. **Numeric Fields**: Cast to FLOAT with null handling

## Querying the Data

### Sample Queries

#### Get Daily COVID Metrics
```sql
SELECT 
    c.country_name,
    f.date_key,
    f.new_cases_7day_avg,
    f.new_deaths_7_day_avg,
    f.stringency_index
FROM gold.fact_covid_daily f
JOIN gold.dim_country c ON f.country_key = c.country_key
WHERE c.country_name = 'United States'
ORDER BY f.date_key DESC
LIMIT 30;
```

#### Compare Countries
```sql
SELECT 
    c.country_name,
    SUM(f.new_cases_per_month) as total_cases,
    SUM(f.new_deaths_per_month) as total_deaths,
    AVG(f.new_deaths_per_month::float / NULLIF(f.new_cases_per_month, 0)) * 100 as avg_case_fatality_rate
FROM gold.fact_covid_monthly f
JOIN gold.dim_country c ON f.country_key = c.country_key
WHERE c.country_name IN ('United States', 'United Kingdom', 'Germany', 'France')
GROUP BY c.country_name
ORDER BY total_cases DESC;
```

#### ML Features for Prediction
```sql
SELECT 
    country_key,
    date_key,
    cases_lag_7d,
    deaths_lag_14d,
    stringency_index,
    case_fatality_rate,
    target_cases,
    target_deaths
FROM gold.ml_features
WHERE country_key = 'USA'
    AND date_key >= '2020-01-01'
    AND cases_lag_7d IS NOT NULL
ORDER BY date_key;
```

## Schema Evolution

### Adding New Sources

1. Add CSV file to `data/raw/`
2. Create table in PostgreSQL (`raw_covid` schema)
3. Load data via COPY or Python
4. Add source to `raw_covid.yml`
5. Create staging model: `stg_raw_covid__new_source.sql`
6. Create bronze model: `brz__new_source.sql`
7. Incorporate into silver/gold models as needed
8. Run `dbt run` to materialize

### Modifying Existing Models

1. Update model SQL file
2. Test locally: `dbt run --select model_name`
3. Run tests: `dbt test --select model_name`
4. Update documentation if schema changes
5. Deploy via Airflow DAG

## Data Refresh Frequency

- **Raw Data**: Manual/batch loads (historical data)
- **dbt Models**: Daily via Airflow DAG
- **Fact Tables**: Full refresh daily (small dataset)
- **Dimensions**: Full refresh (slowly changing)

## Performance Considerations

1. **Indexes**: Create indexes on foreign keys and frequently filtered columns
2. **Partitioning**: Consider partitioning large fact tables by date
3. **Incremental Models**: Can be enabled for very large time-series data
4. **Materialization**: Views for staging (low overhead), tables for higher layers (query performance)

## Documentation

Generate and view dbt documentation:
```bash
cd dbt_covid
dbt docs generate
dbt docs serve
```

This creates an interactive data catalog with:
- Model descriptions
- Column descriptions
- Data lineage graphs
- Test results
- Source freshness
