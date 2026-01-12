# Architecture Documentation

## System Overview

Pandemic Insights is an end-to-end healthcare analytics engineering system designed to process, transform, and analyze COVID-19 pandemic data. The system follows modern data engineering best practices with a medallion architecture pattern and orchestrated transformations.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Data Sources (CSV Files)                    │
│  - COVID cases/deaths    - Demographics      - Health indicators    │
│  - Vaccination data      - Testing data      - Policy data           │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         │ Load via SQL
                         ↓
┌─────────────────────────────────────────────────────────────────────┐
│                    PostgreSQL - raw_covid schema                     │
│                     (Raw data storage layer)                         │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         │ dbt transformations
                         ↓
┌─────────────────────────────────────────────────────────────────────┐
│                        dbt Medallion Architecture                    │
│                                                                       │
│  ┌──────────────┐      ┌──────────────┐      ┌──────────────┐      │
│  │   STAGING    │  →   │    BRONZE    │  →   │    SILVER    │  →   │
│  │   (Views)    │      │   (Tables)   │      │   (Tables)   │      │
│  │              │      │              │      │              │      │
│  │ - Raw source │      │ - Renamed    │      │ - Cleaned    │      │
│  │   references │      │ - Typed      │      │ - Joined     │      │
│  │              │      │ - Timestamped│      │ - Conformed  │      │
│  └──────────────┘      └──────────────┘      └──────────────┘      │
│                                                       │               │
│                                                       ↓               │
│                                              ┌──────────────┐        │
│                                              │     GOLD     │        │
│                                              │   (Tables)   │        │
│                                              │              │        │
│                                              │ - Facts      │        │
│                                              │ - Dimensions │        │
│                                              │ - ML Features│        │
│                                              └──────────────┘        │
└─────────────────────────────────────────────────────────────────────┘
                         │
                         │ Query/Analysis
                         ↓
┌─────────────────────────────────────────────────────────────────────┐
│                     Analytics & Reporting Layer                      │
│              (BI Tools, ML Models, Data Science)                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Orchestration Layer

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Apache Airflow + Cosmos                         │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │                    dbt_covid_dag                            │     │
│  │                                                             │     │
│  │  [staging] → [bronze] → [silver] → [gold]                  │     │
│  │                                                             │     │
│  │  - Daily schedule (@daily)                                 │     │
│  │  - Automatic dependency management via Cosmos              │     │
│  │  - dbt test execution                                      │     │
│  └────────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────┘
```

## Component Architecture

### 1. Data Ingestion Layer
- **Source**: CSV files in `/data/raw/` directory
- **Tables**: 18 raw tables in PostgreSQL `raw_covid` schema
- **Loading**: SQL scripts (`SCHEMA AND LOAD.sql`)

### 2. Transformation Layer (dbt)
- **Tool**: dbt (Data Build Tool)
- **Database**: PostgreSQL
- **Project**: `covid` dbt project
- **Profiles**: Configured in `~/.dbt/profiles.yml`

#### Medallion Architecture Layers:

**Staging Layer** (Views)
- Purpose: Direct source references with minimal transformation
- Materialization: Views
- Pattern: `stg_raw_covid__*`
- Examples: `stg_raw_covid__new_cases_7day_avg`, `stg_raw_covid__vaccine_administered`

**Bronze Layer** (Tables)
- Purpose: Typed, renamed, and timestamped data
- Materialization: Tables
- Schema: `bronze`
- Pattern: `brz__*`
- Examples: `brz__new_cases_7day_avg`, `brz__vaccine_administered`
- Adds: `read_timestamp` for lineage

**Silver Layer** (Tables)
- Purpose: Cleaned, joined, and conformed data
- Materialization: Tables
- Schema: `silver`
- Pattern: `slv_*`
- Examples: `slv_covid_daily`, `slv_covid_monthly`, `slv_geo_health`, `slv_gender_health`
- Features: Data quality rules, standardized naming, business logic

**Gold Layer** (Tables)
- Purpose: Business-ready analytics models
- Materialization: Tables
- Schema: `gold`
- Pattern: `fact_*`, `dim_*`, `ml_*`
- Models:
  - **Facts**: `fact_covid_daily`, `fact_covid_monthly`, `fact_vaccination`, `fact_gender_health`
  - **Dimensions**: `dim_country`, `dim_date`, `dim_gender`
  - **ML Features**: `ml_features` (for predictive modeling)

### 3. Orchestration Layer
- **Tool**: Apache Airflow (Astronomer Runtime)
- **Framework**: Astronomer Cosmos (dbt + Airflow integration)
- **DAG**: `dbt_covid_dag`
- **Schedule**: Daily (`@daily`)
- **Deployment**: Dockerized via Astronomer

### 4. Storage Layer
- **Database**: PostgreSQL
- **Schemas**:
  - `raw_covid`: Raw source data
  - `bronze`: Bronze layer tables
  - `silver`: Silver layer tables
  - `gold`: Gold layer tables

## Technology Stack

### Core Technologies
| Component | Technology | Version |
|-----------|-----------|---------|
| Database | PostgreSQL | Latest |
| Transformation | dbt-core | Latest |
| Database Adapter | dbt-postgres | Latest |
| Orchestration | Apache Airflow | via Astronomer Runtime 3.1-9 |
| Containerization | Docker | Latest |
| Airflow Framework | Astronomer Cosmos | Latest |

### Additional Technologies
- **Python Libraries**: pandas, numpy, sqlalchemy
- **ML Libraries**: scikit-learn, xgboost, lightgbm
- **Visualization**: plotly
- **Testing**: pytest, pytest-cov
- **Code Quality**: black

### Multi-Database Support (Optional)
The dbt project includes adapters for:
- PostgreSQL (primary)
- BigQuery
- Snowflake
- Redshift

## Data Flow

1. **Ingestion**: CSV files → PostgreSQL `raw_covid` schema
2. **Staging**: dbt creates views referencing raw tables
3. **Bronze**: dbt materializes typed and renamed tables
4. **Silver**: dbt creates cleaned and joined datasets
5. **Gold**: dbt builds star schema (facts & dimensions) and ML features
6. **Orchestration**: Airflow schedules and monitors daily dbt runs
7. **Consumption**: Analytics tools query gold layer tables

## Key Design Principles

### 1. Medallion Architecture
- Progressive refinement of data quality
- Clear separation of concerns
- Enables both detailed and aggregated analysis

### 2. Idempotency
- All dbt models are idempotent (can be run multiple times safely)
- Enables reliable pipeline recovery and reprocessing

### 3. Modularity
- Each layer has specific responsibility
- Models reference upstream models via `{{ ref() }}`
- Easy to test and maintain individual components

### 4. Data Quality
- Source tests defined in `raw_covid.yml`
- Data type enforcement at bronze layer
- Business rule validation at silver/gold layers

### 5. Performance
- Strategic materialization choices:
  - Views for staging (no storage overhead)
  - Tables for bronze/silver/gold (query performance)
- Incremental models supported for large time-series data

## Deployment Architecture

### Development Environment
```
Local Machine
├── dbt CLI
├── PostgreSQL connection
└── Git repository
```

### Production Environment (Airflow)
```
Docker Containers (via Astronomer)
├── Airflow Webserver
├── Airflow Scheduler
├── Airflow Worker
├── PostgreSQL (metadata DB)
└── dbt virtual environment
    └── PostgreSQL connection (covid database)
```

## Security Considerations

1. **Credentials Management**:
   - Database credentials stored in Airflow Connections
   - dbt profiles use connection ID references
   - No hardcoded credentials in code

2. **Access Control**:
   - Schema-level permissions in PostgreSQL
   - Airflow RBAC for DAG access

3. **Data Privacy**:
   - Aggregated data only (no PII)
   - Public health data sources

## Scalability Considerations

1. **Incremental Processing**: Support for incremental models in dbt config
2. **Partitioning**: Can be implemented for large fact tables
3. **Multi-Database**: Adapters available for cloud data warehouses (BigQuery, Snowflake, Redshift)
4. **Horizontal Scaling**: Airflow workers can be scaled

## Monitoring and Observability

1. **Airflow UI**: DAG run history, task logs, execution times
2. **dbt Logs**: Model compilation and execution logs
3. **Data Quality**: dbt test results in Airflow
4. **Metadata**: `read_timestamp` in bronze layer for data lineage

## Future Enhancements

1. **Data Quality Framework**: Implement dbt expectations or custom data quality tests
2. **Alerting**: Email/Slack notifications on pipeline failures
3. **Documentation**: Auto-generate dbt docs and host on web server
4. **CI/CD**: Automated testing and deployment pipeline
5. **API Layer**: REST API for serving gold layer data
6. **Real-time Processing**: Stream processing for near real-time updates
7. **ML Pipeline**: Automated model training and deployment
