# COVID-19 dbt Project (Airflow Mounted)

> **Note**: This is the dbt project mounted into the Airflow DAG directory for execution by Cosmos.
> For comprehensive dbt project documentation, see the main dbt project at `/covid/README.md` in the repository root.

## Quick Reference

This directory contains the COVID-19 analytics dbt project that is executed by Apache Airflow via Astronomer Cosmos.

### Running Commands

**From Airflow container**:
```bash
# Access the Airflow container
astro dev bash

# Activate dbt virtual environment
source /usr/local/airflow/dbt_venv/bin/activate

# Run dbt commands
cd /usr/local/airflow/dags/covid
dbt run
dbt test
```

**For local development**, use the main dbt project at repository root:
```bash
cd ../../covid
dbt run
dbt test
```

### Key Files

- `dbt_project.yml`: Project configuration
- `models/`: Data transformation models (staging, bronze, silver, gold)
- `tests/`: Custom data quality tests
- `macros/`: Reusable SQL snippets
- `packages.yml`: dbt package dependencies

### Model Layers

1. **Staging** (`models/staging/`): Source data extraction
2. **Bronze** (`models/bronze/`): Raw data with audit metadata  
3. **Silver** (`models/silver/`): Cleaned and conformed data
4. **Gold** (`models/gold/`): Dimensional models and ML features

### Documentation

For detailed documentation on:
- Model architecture and lineage
- Development workflow
- Testing strategies
- Best practices

Please refer to:
- Main dbt project README: `/covid/README.md`
- Main repository README: `/README.md`
- Airflow project README: `/covid_dbt_dag/README.md`

### Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [Astronomer Cosmos](https://astronomer.github.io/astronomer-cosmos/)
- [Project Repository](https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System)

