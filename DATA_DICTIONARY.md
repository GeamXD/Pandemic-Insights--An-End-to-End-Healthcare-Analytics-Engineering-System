# Data Dictionary

## Overview

This document provides detailed information about the data models, tables, and columns in the Pandemic Insights analytics system. The system follows a medallion architecture with four layers: Staging, Bronze, Silver, and Gold.

## Table of Contents

- [Data Architecture](#data-architecture)
- [Naming Conventions](#naming-conventions)
- [Raw Data Sources](#raw-data-sources)
- [Bronze Layer](#bronze-layer)
- [Silver Layer](#silver-layer)
- [Gold Layer](#gold-layer)
- [Data Types](#data-types)
- [Business Metrics](#business-metrics)

## Data Architecture

```
Raw Sources (CSV) → Staging (Views) → Bronze (Tables) → Silver (Tables) → Gold (Tables)
```

### Layer Purposes

| Layer | Purpose | Materialization | Schema |
|-------|---------|-----------------|--------|
| **Raw** | Source CSV files | Files | N/A |
| **Staging** | Direct source extraction | Views | staging |
| **Bronze** | Raw data with metadata | Tables | bronze |
| **Silver** | Cleaned, conformed data | Tables | silver |
| **Gold** | Dimensional models | Tables | gold |

## Naming Conventions

### Prefixes

- `stg_`: Staging models (views)
- `brz__`: Bronze models (tables with audit columns)
- `slv_`: Silver models (cleaned tables)
- `dim_`: Dimension tables (gold layer)
- `fact_`: Fact tables (gold layer)
- `ml_`: Machine learning features (gold layer)

### Suffixes

- `_7day_avg`: 7-day rolling average
- `_per_month`: Monthly aggregation
- `_index`: Index or composite metric
- `_rate`: Calculated percentage or rate

## Raw Data Sources

### Schema: `raw_covid`

All raw tables share a common structure:

| Column | Type | Description |
|--------|------|-------------|
| Geography | VARCHAR(256) | Country/region code or name |
| Indicator | VARCHAR(256) | Metric being measured |
| Count | VARCHAR(256) | Numeric value (stored as string) |
| date | VARCHAR(256) | Date in YYYY-MM-DD format (time-series only) |

### Time-Series Tables

#### `new_cases_7day_avg`
**Description**: 7-day rolling average of new COVID-19 cases

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "USA" | Country code |
| date | "2021-03-15" | Date of measurement |
| Indicator | "New cases (7-day avg)" | Metric name |
| Count | "65234.5" | 7-day average of new cases |

#### `new_deaths_7_day_avg`
**Description**: 7-day rolling average of COVID-19 deaths

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "GBR" | Country code |
| date | "2021-03-15" | Date of measurement |
| Indicator | "New deaths (7-day avg)" | Metric name |
| Count | "142.3" | 7-day average of deaths |

#### `new_cases_per_month`
**Description**: Total new cases aggregated by month

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "FRA" | Country code |
| date | "2021-03" | Year-month |
| Indicator | "New cases (monthly)" | Metric name |
| Count | "1250000" | Total monthly cases |

#### `new_deaths_per_month`
**Description**: Total deaths aggregated by month

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "DEU" | Country code |
| date | "2021-03" | Year-month |
| Indicator | "New deaths (monthly)" | Metric name |
| Count | "8500" | Total monthly deaths |

#### `stringency_index`
**Description**: Government response stringency measure (0-100)

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "ITA" | Country code |
| date | "2021-03-15" | Date of measurement |
| Count | "75.5" | Stringency score (0=no measures, 100=strictest) |

Source: Oxford COVID-19 Government Response Tracker

#### `tests_conducted_7_day_avg`
**Description**: 7-day average of COVID-19 tests conducted

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "KOR" | Country code |
| date | "2021-03-15" | Date of measurement |
| Indicator | "Tests (7-day avg)" | Metric name |
| Count | "50000" | Average daily tests |

#### `vaccine_administered`
**Description**: Cumulative vaccines administered

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "ISR" | Country code |
| Indicator | "Total vaccines" | Metric type |
| Count | "5000000" | Total doses administered |

### Static Country Tables

#### `population`
**Description**: Population statistics by country

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "JPN" | Country code |
| Indicator | "Population" | Metric name |
| Count | "126000000" | Total population |

#### `diabetes_prevalence`
**Description**: Percentage of population with diabetes

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "USA" | Country code |
| Indicator | "Diabetes prevalence" | Metric name |
| Count | "10.5" | Percentage (%) |

#### `smoking`
**Description**: Smoking prevalence rates

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "FRA" | Country code |
| Indicator | "Smoking prevalence" | Metric name |
| Count | "25.4" | Percentage (%) |

#### `gross_domestic_product`
**Description**: GDP per capita (USD)

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "CHE" | Country code |
| Indicator | "GDP per capita" | Metric name |
| Count | "85000" | USD per person |

#### `human_development_index`
**Description**: HDI score (0-1)

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "NOR" | Country code |
| Indicator | "HDI" | Metric name |
| Count | "0.957" | HDI score |

Source: UN Human Development Reports

#### `high_risk_age_groups`
**Description**: Percentage of population in high-risk age groups

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "ITA" | Country code |
| Indicator | "Aged 65+ years" | Age group |
| Count | "23.5" | Percentage (%) |

Indicators: "Aged 65+ years", "Aged 70+ years"

#### `median_age_and_life_expectancy`
**Description**: Age demographics

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "JPN" | Country code |
| Indicator | "Median age" | Metric name |
| Count | "48.4" | Years |

Indicators: "Median age", "Life expectancy"

#### `hopsital_beds_and_handwashing`
**Description**: Healthcare infrastructure metrics

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "DEU" | Country code |
| Indicator | "Hospital beds per 1000" | Metric name |
| Count | "8.0" | Beds per 1000 population |

Indicators: "Hospital beds per 1000", "Handwashing facilities (%)"

#### `death_rate_from_cardiovascular_disease`
**Description**: CVD mortality rate

| Column | Sample Value | Description |
|--------|--------------|-------------|
| Geography | "USA" | Country code |
| Indicator | "CVD death rate" | Metric name |
| Count | "151.0" | Deaths per 100,000 |

## Bronze Layer

### Schema: `bronze`

Bronze tables add audit metadata to raw data:

**Additional Columns**:
- `read_timestamp`: TIMESTAMP - When data was loaded

**Naming Pattern**: `brz__<table_name>`

**Example**: `brz__new_cases_7day_avg`

| Column | Type | Description |
|--------|------|-------------|
| geography | VARCHAR(256) | Country code (unchanged) |
| date | VARCHAR(256) | Date string (unchanged) |
| new_cases_7day_avg_indicator | VARCHAR(256) | Renamed indicator |
| new_cases_7day_avg | VARCHAR(256) | Renamed count |
| read_timestamp | TIMESTAMP | Load timestamp |

## Silver Layer

### Schema: `silver`

Silver tables contain cleaned, typed, and joined data.

### `slv_covid_daily`
**Description**: Daily COVID-19 metrics joined across multiple sources

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| code | VARCHAR | No | Country code (trimmed) |
| date | DATE | No | Date of measurement |
| new_cases_7day_avg | FLOAT | Yes | 7-day avg new cases |
| new_deaths_7_day_avg | FLOAT | Yes | 7-day avg deaths |
| stringency_index | FLOAT | Yes | Government response score (0-100) |
| test_count | FLOAT | Yes | Daily tests (7-day avg) |

**Grain**: One row per country per date

**Joins**: 
- new_cases_7day_avg (LEFT)
- new_deaths_7_day_avg (LEFT)
- stringency_index (LEFT)
- tests_conducted_7_day_avg (LEFT)

**Filters**:
- Removes rows where geography or critical values are null
- Converts "Null" strings to actual nulls

### `slv_covid_monthly`
**Description**: Monthly aggregated COVID-19 data

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| code | VARCHAR | No | Country code |
| date | DATE | No | Month (first day of month) |
| new_cases_monthly | FLOAT | Yes | Total monthly cases |
| new_deaths_monthly | FLOAT | Yes | Total monthly deaths |

**Grain**: One row per country per month

### `slv_geo_health`
**Description**: Country-level health and demographic indicators

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| code | VARCHAR | No | Country code |
| population | FLOAT | Yes | Total population |
| pct_diabetes | FLOAT | Yes | Diabetes prevalence (%) |
| pct_smoking | FLOAT | Yes | Smoking prevalence (%) |
| gdp_per_capita | FLOAT | Yes | GDP per capita (USD) |
| pct_65_plus | FLOAT | Yes | % population aged 65+ |
| pct_70_plus | FLOAT | Yes | % population aged 70+ |
| median_age | FLOAT | Yes | Median age (years) |
| life_expectancy | FLOAT | Yes | Life expectancy (years) |
| pct_hos_beds | FLOAT | Yes | Hospital beds per 1000 |
| pct_handwashing | FLOAT | Yes | % with handwashing facilities |
| hum_dev_index | FLOAT | Yes | HDI score (0-1) |
| cvd_death_rate | FLOAT | Yes | CVD deaths per 100k |
| population_density_2020 | FLOAT | Yes | People per sq km |

**Grain**: One row per country

**Calculated Fields**:
- `population_density_2020`: Derived from population and area

### `slv_gender_health`
**Description**: Gender-specific health metrics

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| code | VARCHAR | No | Country code |
| gender | VARCHAR | No | Gender identifier |
| metric_name | VARCHAR | No | Health metric |
| metric_value | FLOAT | Yes | Metric value |

**Grain**: One row per country per gender per metric

## Gold Layer

### Schema: `gold`

Gold layer contains dimensional models ready for analysis and ML.

### Dimension Tables

#### `dim_country`
**Description**: Country dimension with health and demographic attributes

| Column | Type | Key | Description |
|--------|------|-----|-------------|
| country_key | INTEGER | PK | Surrogate key |
| country_code | VARCHAR | NK | Country code (natural key) |
| country_name | VARCHAR | | Full country name |
| population | FLOAT | | Total population |
| pct_diabetes | FLOAT | | Diabetes prevalence (%) |
| pct_smoking | FLOAT | | Smoking prevalence (%) |
| gdp_per_capita | FLOAT | | GDP per capita (USD) |
| pct_65_plus | FLOAT | | % aged 65+ |
| pct_70_plus | FLOAT | | % aged 70+ |
| median_age | FLOAT | | Median age |
| life_expectancy | FLOAT | | Life expectancy |
| pct_hos_beds | FLOAT | | Hospital beds per 1000 |
| pct_handwashing | FLOAT | | % with handwashing |
| hum_dev_index | FLOAT | | HDI score |
| cvd_death_rate | FLOAT | | CVD mortality rate |
| population_density_2020 | FLOAT | | Population density |

**Grain**: One row per country

#### `dim_date`
**Description**: Date dimension for time-based analysis

| Column | Type | Key | Description |
|--------|------|-----|-------------|
| date_key | DATE | PK | Date (primary key) |
| day | INTEGER | | Day of month (1-31) |
| month | INTEGER | | Month (1-12) |
| year | INTEGER | | Year |
| quarter | INTEGER | | Quarter (1-4) |
| day_of_week | INTEGER | | Day of week (0=Sunday) |
| day_name | VARCHAR | | Day name (Monday, etc.) |
| month_name | VARCHAR | | Month name (January, etc.) |
| is_weekend | BOOLEAN | | True if Saturday/Sunday |
| week_of_year | INTEGER | | ISO week number |

**Grain**: One row per date

#### `dim_gender`
**Description**: Gender dimension

| Column | Type | Key | Description |
|--------|------|-----|-------------|
| gender_key | INTEGER | PK | Surrogate key |
| gender_code | VARCHAR | NK | Gender code |
| gender_name | VARCHAR | | Gender description |

**Grain**: One row per gender

### Fact Tables

#### `fact_covid_daily`
**Description**: Daily COVID-19 metrics fact table

| Column | Type | Key/Measure | Description |
|--------|------|-------------|-------------|
| country_key | INTEGER | FK | Foreign key to dim_country |
| date_key | DATE | FK | Foreign key to dim_date |
| new_cases_7day_avg | FLOAT | Measure | 7-day avg cases |
| new_deaths_7_day_avg | FLOAT | Measure | 7-day avg deaths |
| stringency_index | FLOAT | Measure | Government response score |
| test_count | FLOAT | Measure | Daily tests |

**Grain**: One row per country per date

**Keys**: Composite key (country_key, date_key)

**Relationships**:
- → dim_country (many-to-one)
- → dim_date (many-to-one)

#### `fact_covid_monthly`
**Description**: Monthly COVID-19 aggregates

| Column | Type | Key/Measure | Description |
|--------|------|-------------|-------------|
| country_key | INTEGER | FK | Foreign key to dim_country |
| date_key | DATE | FK | Foreign key to dim_date (month start) |
| new_cases_monthly | FLOAT | Measure | Total monthly cases |
| new_deaths_monthly | FLOAT | Measure | Total monthly deaths |

**Grain**: One row per country per month

#### `fact_gender_health`
**Description**: Gender-specific health metrics

| Column | Type | Key/Measure | Description |
|--------|------|-------------|-------------|
| country_key | INTEGER | FK | Foreign key to dim_country |
| gender_key | INTEGER | FK | Foreign key to dim_gender |
| metric_value | FLOAT | Measure | Health metric value |

**Grain**: One row per country per gender per metric

#### `fact_vaccination`
**Description**: Vaccination progress tracking

| Column | Type | Key/Measure | Description |
|--------|------|-------------|-------------|
| country_key | INTEGER | FK | Foreign key to dim_country |
| date_key | DATE | FK | Foreign key to dim_date |
| total_vaccinations | FLOAT | Measure | Cumulative doses |
| daily_vaccinations | FLOAT | Measure | Daily doses |
| pct_population_vaccinated | FLOAT | Measure | % with at least one dose |

**Grain**: One row per country per date

### Machine Learning Features

#### `ml_features`
**Description**: Time-series and static features for predictive modeling

| Column | Type | Feature Type | Description |
|--------|------|--------------|-------------|
| country_key | INTEGER | Key | Country identifier |
| date_key | DATE | Key | Date |
| **Target Variables** |
| target_deaths | FLOAT | Target | Deaths to predict |
| target_cases | FLOAT | Target | Cases to predict |
| **Time Series Features** |
| cases_lag_7d | FLOAT | Lag | Cases 7 days prior |
| deaths_lag_14d | FLOAT | Lag | Deaths 14 days prior |
| **Policy Features** |
| stringency_index | FLOAT | Current | Current policy stringency |
| stringency_lag_14d | FLOAT | Lag | Stringency 14 days prior |
| **Testing Features** |
| test_count | FLOAT | Current | Daily test volume |
| **Country Features** |
| pct_70_plus | FLOAT | Static | High-risk population |
| pct_diabetes | FLOAT | Static | Comorbidity prevalence |
| pct_hos_beds | FLOAT | Static | Healthcare capacity |
| hum_dev_index | FLOAT | Static | Development level |
| population_density_2020 | FLOAT | Static | Population density |
| **Calculated Metrics** |
| case_fatality_rate | FLOAT | Derived | (Deaths/Cases) * 100 |

**Grain**: One row per country per date

**Purpose**: Ready for ML models to predict COVID-19 outcomes

**Feature Engineering**:
- Lag features capture time dependencies
- Static features provide country context
- Calculated metrics combine multiple signals

## Data Types

### Type Conversions

| Raw Type | Bronze Type | Silver Type | Gold Type |
|----------|-------------|-------------|-----------|
| VARCHAR | VARCHAR | FLOAT/DATE | FLOAT/DATE/INTEGER |

### NULL Handling

- **Bronze**: Preserves nulls from source
- **Silver**: Converts "Null" strings to SQL NULL, filters critical nulls
- **Gold**: Uses NULLIF for safe division, COALESCE for defaults

## Business Metrics

### Calculated Metrics

#### Case Fatality Rate
```sql
(new_deaths_7_day_avg / NULLIF(new_cases_7day_avg, 0)) * 100
```
Percentage of confirmed cases that result in death.

#### Population Density
```sql
population / land_area_sq_km
```
People per square kilometer.

#### Vaccination Rate
```sql
(total_vaccinations / population) * 100
```
Percentage of population with at least one dose.

### Key Performance Indicators

- **Daily Cases Trend**: 7-day average new cases
- **Mortality Rate**: Deaths per 100,000 population
- **Healthcare Capacity**: Hospital beds per 1000
- **Policy Response**: Stringency index (0-100)
- **Testing Coverage**: Tests per 1000 population

## Data Refresh

- **Frequency**: Daily (via Airflow)
- **Schedule**: Midnight UTC
- **Incremental**: Yes (for time-series data)
- **Full Refresh**: Weekly (for static dimensions)

## Data Quality

### Tests Applied

- **not_null**: Critical fields must have values
- **unique**: Primary keys must be unique
- **relationships**: Foreign keys must exist
- **accepted_values**: Enums must match allowed values
- **custom**: Business logic validations

### Data Lineage

Use `dbt docs` to view full lineage:
```bash
cd covid
dbt docs generate
dbt docs serve
```

## Change Log

- **v1.0** (2023-09): Initial data models
- **v1.1** (2024-01): Added ML features table

---

**For questions or corrections, please open an issue on GitHub.**
