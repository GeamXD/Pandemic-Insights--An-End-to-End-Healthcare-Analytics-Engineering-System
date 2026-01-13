# Pandemic Insights: An End-to-End Healthcare Analytics Engineering System

[![dbt](https://img.shields.io/badge/dbt-Analytics-orange)](https://www.getdbt.com/)
[![Airflow](https://img.shields.io/badge/Apache-Airflow-blue)](https://airflow.apache.org/)
[![BigQuery](https://img.shields.io/badge/Google-BigQuery-blue)](https://cloud.google.com/bigquery)
[![Python](https://img.shields.io/badge/Python-3.8+-green)](https://www.python.org/)

A comprehensive, production-ready data analytics platform for COVID-19 pandemic data analysis. This system demonstrates modern data engineering best practices with a medallion architecture, automated orchestration, and ML-ready feature engineering.

## 🎯 Overview

Pandemic Insights is an end-to-end healthcare analytics engineering system that:
- **Ingests** COVID-19 data from multiple sources (cases, deaths, vaccinations, testing, demographics, health indicators)
- **Transforms** raw data through a medallion architecture (Bronze → Silver → Gold)
- **Models** data using dimensional modeling (facts and dimensions)
- **Orchestrates** daily data pipelines with Apache Airflow
- **Prepares** ML-ready features for predictive modeling

## 🏗️ Architecture

```
Data Sources (CSV) → BigQuery → dbt (Medallion Architecture) → Analytics/ML
                                      ↑
                                 Airflow Orchestration
```

**Key Components:**
- **Data Storage**: Google BigQuery with multi-dataset design
- **Transformation**: dbt (Data Build Tool) with medallion architecture
- **Orchestration**: Apache Airflow via Astronomer Cosmos
- **Deployment**: Docker containerization

**Layers:**
- **Staging**: Direct source references (views)
- **Bronze**: Typed and timestamped data (tables)
- **Silver**: Cleaned and joined datasets (tables)
- **Gold**: Star schema with facts, dimensions, and ML features (tables)

## 📊 Data Model

### Fact Tables
- `fact_covid_daily`: Daily COVID metrics by country
- `fact_covid_monthly`: Monthly aggregated metrics
- `fact_vaccination`: Vaccination statistics
- `fact_gender_health`: Gender-specific health metrics

### Dimension Tables
- `dim_country`: Country attributes and health indicators
- `dim_date`: Date dimension with time intelligence
- `dim_gender`: Gender dimension

### ML Features
- `ml_features`: Pre-computed features for predictive modeling with lag variables, policy features, and calculated metrics

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- Google Cloud Platform account with BigQuery enabled
- Docker & Docker Compose (for Airflow)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System.git
   cd Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System
   ```

2. **Set up BigQuery dataset**
   ```bash
   # Create BigQuery dataset (via gcloud CLI or GCP Console)
   gcloud config set project YOUR_PROJECT_ID
   bq mk --dataset --location=US covid
   # Load raw data using the provided shell script
   ./raw_files_to_bigquery.sh
   ```

3. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure dbt**
   - Edit `~/.dbt/profiles.yml` with your BigQuery credentials
   - See [docs/SETUP.md](docs/SETUP.md) for detailed configuration

5. **Run dbt models**
   ```bash
   cd dbt_covid
   dbt deps
   dbt run
   ```

6. **Start Airflow (optional)**
   ```bash
   cd dbt_covid_dag
   astro dev start
   ```

## 📚 Documentation

Comprehensive technical documentation is available in the `docs/` directory:

- **[Architecture Documentation](docs/ARCHITECTURE.md)**: System design, components, and data flow
- **[Setup Guide](docs/SETUP.md)**: Detailed installation and configuration instructions
- **[Data Model](docs/DATA_MODEL.md)**: Complete data model documentation with schemas and lineage
- **[Development Guide](docs/DEVELOPMENT.md)**: Development workflow, best practices, and guidelines

## 🛠️ Technology Stack

| Layer | Technology |
|-------|-----------|
| Database | Google BigQuery |
| Transformation | dbt (Data Build Tool) |
| Orchestration | Apache Airflow + Astronomer Cosmos |
| Languages | SQL, Python |
| Containerization | Docker |
| ML Libraries | scikit-learn, XGBoost, LightGBM |
| Visualization | Plotly |

## 📁 Project Structure

```
├── dbt_covid/          # dbt project
│   ├── models/         # dbt models (staging, bronze, silver, gold)
│   ├── tests/          # Data quality tests
│   └── dbt_project.yml # dbt configuration
├── dbt_covid_dag/      # Airflow project
│   ├── dags/           # Airflow DAGs
│   └── Dockerfile      # Airflow container
├── data/               # Raw data files
│   └── raw/           # CSV source files
├── docs/              # Technical documentation
├── requirements.txt   # Python dependencies
├── raw_files_to_bigquery.sh # BigQuery data loading script
└── SCHEMA AND LOAD.sql # Legacy database schema (PostgreSQL)
```

## 🧪 Testing

Run dbt tests to ensure data quality:

```bash
cd dbt_covid
dbt test
```

Generate and view documentation:

```bash
dbt docs generate
dbt docs serve
```

## 🔄 Data Pipeline

The pipeline runs daily via Airflow and processes data through these stages:

1. **Staging**: Reference raw tables
2. **Bronze**: Type casting and standardization
3. **Silver**: Data cleaning and joining
4. **Gold**: Business logic and star schema
5. **Testing**: Automated data quality checks

## 📈 Use Cases

This system supports:
- **Pandemic Tracking**: Monitor COVID-19 cases, deaths, and testing trends
- **Policy Analysis**: Analyze impact of government interventions
- **Health Correlation**: Study relationships between demographics and outcomes
- **Predictive Modeling**: ML features for forecasting cases and deaths
- **Comparative Analysis**: Compare countries across multiple dimensions
## Business Presentation
- Canva link: [link](www.google.com)

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests and documentation
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

See [DEVELOPMENT.md](docs/DEVELOPMENT.md) for detailed guidelines.

## 📝 License

This project is available for educational and research purposes.

## 🙏 Acknowledgments

- Data sources: COVID-19 public health datasets
- Tools: dbt Labs, Apache Airflow, Astronomer
- Community: Data engineering and analytics communities

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

---

**Note**: This is a demonstration project showcasing data engineering best practices. For production use, additional considerations for security, scalability, and compliance may be required.
