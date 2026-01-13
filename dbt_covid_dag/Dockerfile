FROM astrocrpublic.azurecr.io/runtime:3.1-9

RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir --default-timeout=100 dbt-core==1.8.9 dbt-bigquery==1.8.9 && \
    deactivate