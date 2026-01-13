# Pandemic Insights: An End-to-End Healthcare Analytics Engineering System

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Data Pipeline Layers](#data-pipeline-layers)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup and Installation](#setup-and-installation)
- [Configuration](#configuration)
- [Data Sources](#data-sources)
- [Usage](#usage)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🎯 Overview

Pandemic Insights is a comprehensive end-to-end healthcare analytics engineering system designed to process, transform, and analyze COVID-19 pandemic data. The system implements a modern data stack using:

- **dbt (Data Build Tool)**: For data transformation and modeling
- **Apache Airflow**: For workflow orchestration
- **Google BigQuery**: As the cloud data warehouse
- **Astronomer**: For Airflow deployment and management

The project follows the medallion architecture (Bronze, Silver, Gold layers) to ensure data quality, maintainability, and scalability.

### Key Features
- **Multi-layered data architecture** for progressive data refinement
- **Automated data pipelines** with Apache Airflow
- **Dimensional data modeling** for analytical queries
- **Machine learning ready features** for predictive analytics
- **Comprehensive data quality tests** using dbt
- **Scalable infrastructure** using containerization

## 🏗️ Architecture

The system follows a layered data architecture:

```
┌─────────────────┐
│   Raw Data      │ CSV files in /data/raw
│   Sources       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Staging Layer  │ Initial data ingestion (Views)
│  (stg_*)        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Bronze Layer   │ Raw data with metadata (Tables)
│  (brz_*)        │ Schema: bronze
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Silver Layer   │ Cleaned, conformed data (Tables)
│  (slv_*)        │ Schema: silver
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Gold Layer    │ Business-ready aggregates (Tables)
│  (dim_*, fact_*)│ Schema: gold
└─────────────────┘
```

### Technology Stack
- **Orchestration**: Apache Airflow (via Astronomer)
- **Transformation**: dbt-core with BigQuery adapter
- **Data Warehouse**: Google BigQuery
- **Containerization**: Docker
- **Python Version**: 3.x
- **Additional Libraries**: pandas, numpy, scikit-learn, xgboost, lightgbm, plotly

## 📊 Data Pipeline Layers

### 1. Staging Layer (`staging/`)
- **Purpose**: Initial data ingestion from raw sources
- **Materialization**: Views
- **Naming Convention**: `stg_raw_covid__*`
- **Transformation**: Minimal - direct pass-through from sources
- **Example**: `stg_raw_covid__new_cases_7day_avg.sql`

### 2. Bronze Layer (`bronze/`)
- **Purpose**: Store raw data with metadata and timestamps
- **Materialization**: Tables
- **Schema**: `bronze`
- **Naming Convention**: `brz__*`
- **Transformation**: Add audit columns (read_timestamp)
- **Example**: `brz__new_cases_7day_avg.sql`

### 3. Silver Layer (`silver/`)
- **Purpose**: Cleaned, validated, and conformed data
- **Materialization**: Tables
- **Schema**: `silver`
- **Naming Convention**: `slv_*`
- **Transformation**: Data cleansing, type casting, joining
- **Example**: `slv_covid_daily.sql`, `slv_geo_health.sql`

### 4. Gold Layer (`gold/`)
- **Purpose**: Business-ready dimensional models and ML features
- **Materialization**: Tables
- **Schema**: `gold`
- **Naming Convention**: `dim_*`, `fact_*`, `ml_*`
- **Models**:
  - **Dimensions**: `dim_country`, `dim_date`, `dim_gender`
  - **Facts**: `fact_covid_daily`, `fact_covid_monthly`, `fact_gender_health`, `fact_vaccination`
  - **ML Features**: `ml_features` (time-series and country-level features for predictive modeling)

## 📁 Project Structure

```
.
├── README.md                          # Main documentation (this file)
├── requirements.txt                   # Python dependencies
├── SCHEMA AND LOAD.sql                # Database schema and load scripts
├── data/
│   └── raw/                          # Raw CSV data files
│       ├── new-cases-7day-avg.csv
│       ├── new-deaths-7-day-avg.csv
│       ├── stringency-index.csv
│       └── ... (15+ datasets)
├── covid/                            # dbt project directory
│   ├── dbt_project.yml              # dbt project configuration
│   ├── packages.yml                  # dbt package dependencies
│   ├── README.md                     # dbt-specific documentation
│   ├── models/
│   │   ├── staging/                 # Staging layer models
│   │   │   ├── raw_covid.yml       # Source definitions
│   │   │   └── stg_raw_covid__*.sql
│   │   ├── bronze/                  # Bronze layer models
│   │   │   └── brz__*.sql
│   │   ├── silver/                  # Silver layer models
│   │   │   ├── slv_covid_daily.sql
│   │   │   ├── slv_covid_monthly.sql
│   │   │   ├── slv_geo_health.sql
│   │   │   └── slv_gender_health.sql
│   │   └── gold/                    # Gold layer models
│   │       ├── dim_country.sql
│   │       ├── dim_date.sql
│   │       ├── dim_gender.sql
│   │       ├── fact_covid_daily.sql
│   │       ├── fact_covid_monthly.sql
│   │       ├── fact_gender_health.sql
│   │       ├── fact_vaccination.sql
│   │       └── ml_features.sql
│   ├── analyses/                    # Ad-hoc SQL analyses
│   ├── tests/                       # Custom data tests
│   ├── macros/                      # Reusable SQL macros
│   ├── seeds/                       # Reference data
│   └── snapshots/                   # Type-2 SCD snapshots
└── covid_dbt_dag/                   # Airflow project directory
    ├── README.md                     # Airflow-specific documentation
    ├── Dockerfile                    # Custom Airflow image
    ├── docker-compose.override.yml   # Local development overrides
    ├── requirements.txt              # Airflow Python dependencies
    ├── packages.txt                  # OS-level packages
    └── dags/
        ├── covid_dag.py             # Main COVID data pipeline DAG
        └── covid/                   # Mounted dbt project

```

## 🔧 Prerequisites

### Required Software
- **Docker Desktop**: Version 20.10 or higher
- **Astronomer CLI**: For local Airflow development
  ```bash
  curl -sSL install.astronomer.io | sudo bash -s
  ```
- **Python**: 3.8 or higher (for dbt development)
- **Google Cloud SDK**: For BigQuery access and authentication
- **Git**: For version control

### System Requirements
- **RAM**: Minimum 8GB (16GB recommended)
- **Disk Space**: 10GB free space
- **OS**: macOS, Linux, or Windows with WSL2

## 🚀 Setup and Installation

### 1. Clone the Repository
```bash
git clone https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System.git
cd Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System
```

### 2. Install Python Dependencies
```bash
# Create virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Set Up Google BigQuery

#### Create BigQuery Dataset
```bash
# Install Google Cloud SDK if not already installed
# https://cloud.google.com/sdk/docs/install

# Authenticate with Google Cloud
gcloud auth login
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Create dataset
bq mk --dataset --location=US YOUR_PROJECT_ID:covid

# Create schema for raw data
bq mk --dataset YOUR_PROJECT_ID:raw_covid
```

#### Alternative: Using BigQuery Console
1. Go to BigQuery Console (https://console.cloud.google.com/bigquery)
2. Create a new dataset named `covid`
3. Create a new dataset named `raw_covid`
4. Upload CSV files from `data/raw/` to BigQuery tables in `raw_covid` dataset

### 4. Load Raw Data
```bash
# Navigate to data directory
cd data/raw

# Use bq command-line tool to load data (example)
bq load --source_format=CSV \
  --skip_leading_rows=1 \
  YOUR_PROJECT_ID:raw_covid.new_cases_7day_avg \
  new-cases-7day-avg.csv \
  Geography:STRING,date:STRING,Indicator:STRING,Count:STRING

# Repeat for all CSV files...
# Or use the BigQuery Console to upload CSV files via the UI
```

### 5. Configure dbt Profile
Create `~/.dbt/profiles.yml`:
```yaml
covid:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: YOUR_PROJECT_ID
      dataset: staging
      threads: 4
      timeout_seconds: 300
      location: US
      priority: interactive
```

For service account authentication:
```yaml
covid:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: YOUR_PROJECT_ID
      dataset: staging
      threads: 4
      keyfile: /path/to/service-account-key.json
      timeout_seconds: 300
      location: US
      priority: interactive
```

### 6. Set Up Airflow (Astronomer)
```bash
cd covid_dbt_dag

# Initialize Astronomer project (if not already done)
astro dev init

# Start Airflow locally
astro dev start
```

The Airflow UI will be available at: `http://localhost:8080`
- **Username**: `admin`
- **Password**: `admin`

## ⚙️ Configuration

### dbt Configuration
The dbt project is configured in `covid/dbt_project.yml`:
- **Project Name**: `covid`
- **Profile**: `covid`
- **Model Paths**: Defines staging, bronze, silver, and gold layers
- **Materialization**: Views for staging, tables for bronze/silver/gold

### Airflow Configuration
The Airflow DAG is configured in `covid_dbt_dag/dags/covid_dag.py`:
- **DAG ID**: `dbt_covid_dag`
- **Schedule**: Daily (`@daily`)
- **Start Date**: September 10, 2023
- **Catchup**: Disabled
- **Connection**: Uses `bigquery_covid` Airflow connection

#### Setting Up Airflow Connection
In the Airflow UI, create a connection:
1. Navigate to **Admin > Connections**
2. Click **+** to add new connection
3. Configure:
   - **Conn Id**: `bigquery_covid`
   - **Conn Type**: `Google Cloud`
   - **Project Id**: `YOUR_PROJECT_ID`
   - **Keyfile Path**: `/path/to/service-account-key.json` (or use Keyfile JSON)
   - **Scopes**: `https://www.googleapis.com/auth/bigquery`

## 📚 Data Sources

The system ingests and processes the following COVID-19 related datasets:

### Time-Series Data
- **new-cases-7day-avg**: 7-day rolling average of new COVID-19 cases
- **new-deaths-7-day-avg**: 7-day rolling average of COVID-19 deaths
- **new-cases-per-month**: Monthly aggregated new cases
- **new-deaths-per-month**: Monthly aggregated deaths
- **tests-conducted-7-day-avg**: Testing volume trends
- **stringency-index**: Government response stringency measures
- **vaccine-administered**: Vaccination progress

### Country-Level Static Data
- **population**: Population statistics
- **diabetes-prevalence**: Diabetes prevalence rates
- **smoking**: Smoking prevalence
- **gross-domestic-product**: GDP indicators
- **human-development-index**: HDI scores
- **high-risk-age-groups**: Age demographics (65+, 70+)
- **median-age-and-life-expectancy**: Age and longevity statistics
- **hospital-beds-and-handwashing**: Healthcare infrastructure
- **death-rate-from-cardiovascular-disease**: Cardiovascular health

### Data Schema
All raw tables follow a consistent structure:
- **Geography**: Country/region identifier
- **Indicator**: Metric being measured
- **Count**: Numeric value
- **Date**: Timestamp (for time-series data)

## 💻 Usage

### Running dbt Models

#### Run All Models
```bash
cd covid
dbt run
```

#### Run Specific Layer
```bash
dbt run --select staging     # Staging layer only
dbt run --select bronze      # Bronze layer only
dbt run --select silver      # Silver layer only
dbt run --select gold        # Gold layer only
```

#### Run Specific Model
```bash
dbt run --select slv_covid_daily
dbt run --select ml_features
```

#### Run Tests
```bash
dbt test                     # All tests
dbt test --select staging   # Staging tests only
```

#### Generate Documentation
```bash
dbt docs generate
dbt docs serve              # Opens documentation in browser
```

### Running Airflow Pipeline

1. **Access Airflow UI**: Navigate to `http://localhost:8080`
2. **Enable the DAG**: Toggle `dbt_covid_dag` to ON
3. **Trigger Manually**: Click the play button to run immediately
4. **Monitor Progress**: View task status and logs in the UI

### Querying the Data Warehouse

```sql
-- Daily COVID metrics
SELECT * FROM gold.fact_covid_daily 
WHERE date >= '2023-01-01' 
ORDER BY date DESC;

-- Country information
SELECT * FROM gold.dim_country;

-- ML-ready features
SELECT * FROM gold.ml_features 
WHERE cases_lag_7d IS NOT NULL;

-- Monthly trends
SELECT * FROM gold.fact_covid_monthly
WHERE date >= '2023-01-01';
```

## 🔄 Development Workflow

### 1. Create Feature Branch
```bash
git checkout -b feature/new-model
```

### 2. Develop dbt Models
```bash
cd covid
# Create/modify models in models/ directory
dbt run --select +my_new_model  # Test locally
dbt test --select +my_new_model
```

### 3. Test in Airflow
```bash
cd covid_dbt_dag
astro dev restart  # Reload DAG
# Test in Airflow UI
```

### 4. Commit and Push
```bash
git add .
git commit -m "Add new model: my_new_model"
git push origin feature/new-model
```

### 5. Create Pull Request
Open a PR on GitHub for review.

## 🧪 Testing

### dbt Tests
The project includes comprehensive data quality tests:

#### Source Tests
Defined in `models/staging/raw_covid.yml`:
- **not_null** checks on critical columns
- Ensures data integrity at the source level

#### Custom Tests
Add custom tests in `tests/` directory:
```sql
-- tests/assert_positive_cases.sql
SELECT *
FROM {{ ref('fact_covid_daily') }}
WHERE new_cases_7day_avg < 0
```

### Running Tests
```bash
# All tests
dbt test

# Specific model tests
dbt test --select slv_covid_daily

# Source tests only
dbt test --select source:*
```

## 🚢 Deployment

### Deploying to Production

#### 1. Production Database Setup
- Create production BigQuery project and datasets
- Set up appropriate IAM permissions
- Configure service account with necessary roles

#### 2. Update dbt Profile
Add production target to `~/.dbt/profiles.yml`:
```yaml
covid:
  target: dev
  outputs:
    dev:
      # ... dev config ...
    prod:
      type: bigquery
      method: service-account
      project: PROD_PROJECT_ID
      dataset: staging
      threads: 8
      keyfile: "{{ env_var('PROD_KEYFILE_PATH') }}"
      timeout_seconds: 300
      location: US
      priority: interactive
```

#### 3. Deploy Airflow to Astronomer
```bash
cd covid_dbt_dag
astro deploy
```

#### 4. Configure Production Connections
Update Airflow connections with production credentials.

### CI/CD Considerations
- Set up automated testing on PR
- Use dbt Cloud or GitHub Actions for dbt runs
- Implement blue-green deployment for schema changes
- Monitor data quality metrics

## 🔍 Troubleshooting

### Common Issues

#### 1. dbt Connection Error
```
Error: Could not connect to database
```
**Solution**: 
- Verify Google Cloud authentication: `gcloud auth application-default login`
- Check `~/.dbt/profiles.yml` configuration
- Verify project ID and dataset names
- Ensure service account has BigQuery permissions
- Test connection: `dbt debug`

#### 2. Airflow DAG Not Appearing
**Solution**:
- Check DAG file syntax: `python covid_dbt_dag/dags/covid_dag.py`
- Restart Airflow: `astro dev restart`
- Check logs: `astro dev logs`

#### 3. dbt Package Installation Fails
```
Error: Package installation failed
```
**Solution**:
```bash
cd covid
dbt clean
dbt deps  # Reinstall packages
```

#### 4. Port Already in Use
```
Error: Port 8080 is already allocated
```
**Solution**:
- Find process: `lsof -i :8080`
- Kill process or change port in `docker-compose.override.yml`

#### 5. Out of Memory
**Solution**:
- Increase Docker memory allocation (Docker Desktop settings)
- Reduce dbt threads in `profiles.yml`
- Process data in smaller batches

### Getting Help
- Check Airflow logs: `astro dev logs`
- Review dbt logs: `cat covid/logs/dbt.log`
- Enable dbt debug mode: `dbt --debug run`

## 🤝 Contributing

### Guidelines
1. Follow existing naming conventions
2. Add tests for new models
3. Update documentation for changes
4. Keep models modular and focused
5. Use descriptive commit messages

### Code Style
- **SQL**: Lowercase keywords, snake_case for identifiers
- **Python**: Follow PEP 8
- **dbt**: Use Jinja templating for reusability

### Submitting Changes
1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit pull request with description

## 📄 License

This project is for educational and research purposes.

## 👥 Authors

- GeamXD - Initial work and architecture

## 🙏 Acknowledgments

- Data sourced from public health organizations
- Built with dbt, Airflow, and Google BigQuery
- Inspired by modern data engineering best practices

---

**Last Updated**: January 2026
