# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **BREAKING**: Migrated from PostgreSQL to Google BigQuery as the primary data warehouse
  - Updated all technical documentation to reflect BigQuery usage
  - Modified DAG configuration to use BigQuery connection
  - Updated SQL syntax in documentation examples for BigQuery compatibility
  - Changed data loading process from SQL scripts to BigQuery CLI/API
- Updated all technical documentation to use correct directory names:
  - `dbt_covid/` instead of `covid/`
  - `dbt_covid_dag/` instead of `covid_dbt_dag/`
- Fixed inconsistencies between documentation and actual repository structure

### Security
- Removed service account key file (key.json) containing sensitive credentials from the repository to improve security and prevent accidental exposure

### Added
- Comprehensive technical documentation suite
  - ARCHITECTURE.md - System architecture and design
  - SETUP.md - Installation and setup guide
  - DATA_MODEL.md - Data model and schema documentation
  - DEVELOPMENT.md - Development guide and best practices
  - docs/README.md - Documentation index
- CONTRIBUTING.md - Contribution guidelines
- CHANGELOG.md - This changelog

### Changed
- Enhanced README.md with better project overview and quick start guide
- Added badges and improved documentation links

## [1.0.0] - Initial Release

### Added

#### dbt Project
- **Staging Layer**: 17 staging models for raw data sources
- **Bronze Layer**: 18 bronze models with type casting and standardization
- **Silver Layer**: 4 silver models with cleaned and joined data
  - `slv_covid_daily` - Daily COVID metrics
  - `slv_covid_monthly` - Monthly aggregated metrics
  - `slv_geo_health` - Geographic and health indicators
  - `slv_gender_health` - Gender-specific health metrics
- **Gold Layer**: 7 gold models with star schema
  - Facts: `fact_covid_daily`, `fact_covid_monthly`, `fact_vaccination`, `fact_gender_health`
  - Dimensions: `dim_country`, `dim_date`, `dim_gender`
  - ML: `ml_features` - Pre-computed features for machine learning

#### Data Sources
- 18 COVID-19 related CSV data files
  - Case and death statistics
  - Vaccination data
  - Testing data
  - Demographic indicators
  - Health indicators
  - Policy measures (stringency index)

#### Database
- Initial PostgreSQL schema creation script (`SCHEMA AND LOAD.sql`) - **Note: Migrated to BigQuery in later version**
- Multi-schema design: `raw_covid`, `bronze`, `silver`, `gold`
- 18 raw data tables

#### Orchestration
- Apache Airflow DAG for automated pipeline execution
- Astronomer Cosmos integration for dbt + Airflow
- Daily schedule configuration
- Dockerized deployment

#### Infrastructure
- Docker configuration for Airflow
- dbt project configuration with medallion architecture
- Python package dependencies
- Requirements files for both root and Airflow projects

#### Testing
- Source data quality tests
- Not null constraints on critical fields
- dbt test framework setup

### Technical Stack
- **Database**: PostgreSQL (Initial version) → Migrated to Google BigQuery
- **Transformation**: dbt (Data Build Tool)
- **Orchestration**: Apache Airflow + Astronomer Cosmos
- **Languages**: SQL, Python
- **Containerization**: Docker
- **ML Libraries**: scikit-learn, XGBoost, LightGBM
- **Data Visualization**: Plotly

### Features
- Medallion architecture (Bronze → Silver → Gold)
- Dimensional modeling with facts and dimensions
- ML-ready feature engineering
- Automated data quality testing
- Daily orchestrated pipeline execution
- Comprehensive data lineage
- Scalable and maintainable design

---

## Version History

### Version Numbering

This project follows Semantic Versioning (SemVer):
- **MAJOR**: Incompatible API/schema changes
- **MINOR**: New functionality in a backward-compatible manner
- **PATCH**: Backward-compatible bug fixes

### Categories

Changes are categorized as:
- **Added**: New features
- **Changed**: Changes to existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security vulnerability fixes

---

## Contributing to Changelog

When making a contribution:

1. Add your changes to the `[Unreleased]` section
2. Use the appropriate category (Added, Changed, Fixed, etc.)
3. Be clear and concise
4. Include references to issues/PRs if applicable
5. Maintainers will update version numbers during releases

Example entry:
```markdown
### Added
- New silver model `slv_hospital_capacity` for tracking hospital metrics (#123)

### Fixed
- Corrected null handling in `fact_covid_daily` (#124)
```

---

## Release Notes

Detailed release notes are available in the [GitHub Releases](https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/releases) page.

[Unreleased]: https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/releases/tag/v1.0.0
