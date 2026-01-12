# Contributing to Pandemic Insights

Thank you for your interest in contributing to the Pandemic Insights project! This guide will help you get started with contributing to this healthcare analytics system.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)
- [Review Process](#review-process)

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect differing viewpoints and experiences
- Accept responsibility and apologize for mistakes

### Expected Behavior

- Use welcoming and inclusive language
- Be patient with questions and explanations
- Provide detailed, actionable feedback
- Focus on the problem, not the person

## Getting Started

### Prerequisites

Before contributing, ensure you have:

1. **Forked the repository** to your GitHub account
2. **Cloned your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System.git
   cd Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System
   ```
3. **Set up your development environment** following the [README.md](README.md)
4. **Configured upstream remote**:
   ```bash
   git remote add upstream https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System.git
   ```

### Types of Contributions

We welcome various types of contributions:

- **Bug fixes**: Fixing issues in existing code
- **New features**: Adding new data models, transformations, or analytics
- **Documentation**: Improving or adding documentation
- **Tests**: Adding or improving test coverage
- **Performance**: Optimizing queries or transformations
- **Refactoring**: Improving code structure without changing functionality

## Development Process

### 1. Create a Feature Branch

Always work on a dedicated feature branch:

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create and switch to a new branch
git checkout -b feature/your-feature-name
```

**Branch Naming Convention**:
- `feature/` - New features or enhancements
- `bugfix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Adding or updating tests

Examples:
- `feature/add-mortality-rate-model`
- `bugfix/fix-null-handling-in-silver`
- `docs/update-installation-guide`

### 2. Make Your Changes

#### For dbt Models

1. **Create model in appropriate layer**:
   ```bash
   # For silver layer
   touch covid/models/silver/slv_your_model.sql
   ```

2. **Follow the medallion architecture**:
   - **Staging**: Direct pass-through from sources
   - **Bronze**: Raw data with metadata
   - **Silver**: Cleaned, validated data
   - **Gold**: Business-ready aggregates

3. **Use proper naming conventions**:
   - Staging: `stg_<source>__<table>`
   - Bronze: `brz__<table>`
   - Silver: `slv_<domain>`
   - Gold: `dim_<dimension>`, `fact_<fact>`, `ml_<purpose>`

4. **Test your model locally**:
   ```bash
   cd covid
   dbt run --select +your_model  # Run with dependencies
   dbt test --select your_model  # Test the model
   ```

#### For Airflow DAGs

1. **Edit or create DAG** in `covid_dbt_dag/dags/`
2. **Follow Airflow best practices**:
   - Use descriptive DAG and task IDs
   - Set appropriate retries and timeouts
   - Add documentation strings
3. **Test DAG syntax**:
   ```bash
   python covid_dbt_dag/dags/your_dag.py
   ```
4. **Test in Airflow**:
   ```bash
   cd covid_dbt_dag
   astro dev start
   # Test in UI at http://localhost:8080
   ```

#### For Python Code

1. **Follow PEP 8** style guidelines
2. **Add type hints** where appropriate
3. **Include docstrings** for functions and classes
4. **Keep functions focused** and modular

### 3. Write Tests

#### dbt Tests

**Schema tests** (in YAML):
```yaml
# covid/models/silver/schema.yml
models:
  - name: slv_your_model
    description: "Description of your model"
    columns:
      - name: id
        description: "Unique identifier"
        tests:
          - unique
          - not_null
      - name: metric_value
        description: "Metric being measured"
        tests:
          - not_null
```

**Custom tests** (in tests/):
```sql
-- covid/tests/assert_valid_dates.sql
SELECT *
FROM {{ ref('slv_your_model') }}
WHERE date > CURRENT_DATE
  OR date < '2019-01-01'
```

**Run tests**:
```bash
dbt test --select your_model
```

#### Airflow Tests

Create test files in `covid_dbt_dag/tests/dags/`:
```python
import pytest
from airflow.models import DagBag

def test_dag_loaded():
    dag_bag = DagBag(include_examples=False)
    assert "your_dag_id" in dag_bag.dags
    assert len(dag_bag.import_errors) == 0
```

### 4. Update Documentation

#### Model Documentation

Add descriptions to YAML files:
```yaml
models:
  - name: slv_your_model
    description: |
      This model combines data from multiple sources to provide...
      
      Business Logic:
      - Filters for valid dates
      - Joins with dimension tables
      - Calculates derived metrics
      
    columns:
      - name: metric_value
        description: "7-day rolling average of cases"
```

#### Code Comments

Add comments for complex logic:
```sql
-- Calculate case fatality rate as percentage
-- Uses NULLIF to avoid division by zero
(deaths / NULLIF(cases, 0)) * 100 AS case_fatality_rate
```

#### README Updates

Update relevant README files if you:
- Add new features
- Change setup process
- Modify configuration
- Add new dependencies

### 5. Commit Your Changes

Follow conventional commit message format:

```bash
git add .
git commit -m "type: brief description

More detailed explanation if needed.
- Bullet points for specific changes
- Reference issue numbers: #123"
```

**Commit Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:
```
feat: add mortality rate model in silver layer

- Creates slv_mortality_rate combining deaths and cases
- Includes age-adjusted calculations
- Adds tests for data quality
```

```
fix: handle null values in slv_covid_daily

Fixes issue where null test counts caused downstream failures.
Now uses COALESCE to default to 0.

Resolves #42
```

## Coding Standards

### SQL Style Guide

**General Rules**:
- Use lowercase for SQL keywords
- Use snake_case for identifiers
- Indent with 4 spaces
- Keep lines under 100 characters when possible

**Example**:
```sql
select
    country_code,
    date,
    sum(new_cases) as total_cases,
    avg(stringency_index) as avg_stringency
from {{ ref('brz__new_cases_7day_avg') }}
where date >= '2020-01-01'
    and country_code is not null
group by 1, 2
order by date desc
```

**Best Practices**:
- Use explicit column names (avoid `SELECT *` in production models)
- Add comments for complex logic
- Use CTEs for readability
- Avoid nested subqueries when possible
- Use `ref()` for model dependencies
- Use `source()` for raw tables

### Python Style Guide

**Follow PEP 8**:
```python
from datetime import datetime
from typing import List, Dict

def calculate_metric(
    values: List[float],
    weights: List[float]
) -> float:
    """
    Calculate weighted average metric.
    
    Args:
        values: List of metric values
        weights: List of weights (must sum to 1.0)
        
    Returns:
        Weighted average as float
        
    Raises:
        ValueError: If weights don't sum to 1.0
    """
    if not abs(sum(weights) - 1.0) < 0.001:
        raise ValueError("Weights must sum to 1.0")
    
    return sum(v * w for v, w in zip(values, weights))
```

### YAML Style Guide

```yaml
# Use 2 spaces for indentation
models:
  - name: model_name
    description: "Clear description"
    columns:
      - name: column_name
        description: "Column purpose"
        tests:
          - not_null
          - unique
```

## Testing Guidelines

### Test Coverage

Aim for comprehensive test coverage:

1. **Source tests**: Verify raw data quality
2. **Model tests**: Ensure transformations are correct
3. **Business logic tests**: Validate calculations
4. **Edge case tests**: Handle nulls, zeros, extremes

### Test Quality

Good tests should:
- **Be specific**: Test one thing at a time
- **Be repeatable**: Same results every time
- **Be fast**: Run quickly for rapid feedback
- **Be meaningful**: Catch real issues

### Running Tests

```bash
# All tests
dbt test

# Specific model
dbt test --select your_model

# Specific layer
dbt test --select silver

# Source tests only
dbt test --select source:*
```

## Documentation

### What to Document

- **Purpose**: What does this model do?
- **Sources**: Where does the data come from?
- **Transformations**: What changes are made?
- **Business logic**: Why these calculations?
- **Assumptions**: What conditions must be true?
- **Limitations**: What are the known issues?

### Documentation Format

```yaml
models:
  - name: slv_covid_metrics
    description: |
      ## Purpose
      Combines daily COVID-19 metrics for analytical queries.
      
      ## Sources
      - brz__new_cases_7day_avg
      - brz__new_deaths_7_day_avg
      - brz__stringency_index
      
      ## Transformations
      - Joins daily metrics by country and date
      - Casts string values to appropriate types
      - Filters out invalid dates
      
      ## Business Logic
      - 7-day averages smooth daily reporting variations
      - Stringency index from Oxford COVID-19 Government Response Tracker
      
      ## Assumptions
      - Country codes are consistent across sources
      - Dates are in YYYY-MM-DD format
```

## Submitting Changes

### 1. Push Your Branch

```bash
git push origin feature/your-feature-name
```

### 2. Create Pull Request

1. Go to the repository on GitHub
2. Click "Pull Requests" → "New Pull Request"
3. Select your branch
4. Fill out the PR template:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
- [ ] dbt tests pass
- [ ] Airflow DAG loads successfully
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No breaking changes (or documented)

## Related Issues
Closes #issue_number
```

### 3. Address Review Comments

- Respond to all comments
- Make requested changes
- Push updates to the same branch
- Re-request review when ready

## Review Process

### What Reviewers Look For

1. **Code Quality**
   - Follows style guidelines
   - Well-organized and readable
   - Properly commented

2. **Functionality**
   - Solves the stated problem
   - Doesn't break existing features
   - Handles edge cases

3. **Testing**
   - Adequate test coverage
   - Tests pass
   - Edge cases covered

4. **Documentation**
   - Changes are documented
   - README updated if needed
   - Clear commit messages

### Timeline

- Initial review: Within 1-2 business days
- Follow-up reviews: Within 1 business day
- Merge: After approval and passing CI

## Questions?

If you have questions or need help:

1. Check existing documentation (README files)
2. Search existing issues on GitHub
3. Open a new issue with the "question" label
4. Be specific about what you're trying to do

## Recognition

Contributors will be recognized in:
- GitHub contributors list
- Project documentation
- Release notes for significant contributions

Thank you for contributing to Pandemic Insights! 🎉
