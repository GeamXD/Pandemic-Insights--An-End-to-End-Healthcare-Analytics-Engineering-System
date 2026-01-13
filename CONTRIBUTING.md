# Contributing to Pandemic Insights

Thank you for your interest in contributing to Pandemic Insights! This document provides guidelines and instructions for contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Contribution Guidelines](#contribution-guidelines)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)

## 🤝 Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please:

- Be respectful and considerate
- Welcome newcomers and help them get started
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

## 🚀 Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System.git
   cd Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System
   ```
3. **Set up your development environment** (see [Development Setup](#development-setup))
4. **Create a branch** for your contribution:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 💡 How to Contribute

### Types of Contributions

We welcome various types of contributions:

#### 🐛 Bug Fixes
- Fix identified bugs
- Add tests to prevent regression
- Update documentation if needed

#### ✨ New Features
- Add new dbt models
- Enhance existing transformations
- Implement new data sources
- Add ML features

#### 📚 Documentation
- Improve existing documentation
- Add examples and tutorials
- Fix typos and clarify content
- Create diagrams or visualizations

#### 🧪 Testing
- Add unit tests for models
- Add integration tests
- Improve test coverage
- Add data quality tests

#### 🎨 Code Quality
- Refactor existing code
- Improve SQL performance
- Enhance code readability
- Follow best practices

## 🛠️ Development Setup

### Prerequisites
- Python 3.8+
- PostgreSQL 12+
- Docker & Docker Compose (for Airflow)
- Git

### Setup Steps

1. **Install Python dependencies**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

2. **Set up PostgreSQL**:
   ```bash
   createdb covid_dev
   psql -d covid_dev -f "SCHEMA AND LOAD.sql"
   ```

3. **Configure dbt profile** (`~/.dbt/profiles.yml`):
   ```yaml
   dbt_covid:
     target: dev
     outputs:
       dev:
         type: postgres
         host: localhost
         user: postgres
         password: your_password
         database: covid_dev
         schema: staging
   ```

4. **Test your setup**:
   ```bash
   cd dbt_covid
   dbt debug
   dbt run
   dbt test
   ```

## 📝 Contribution Guidelines

### Before You Start

1. **Check existing issues** to see if someone is already working on it
2. **Open an issue** to discuss significant changes before implementing
3. **Search closed issues** to see if the topic has been addressed before
4. **Keep changes focused** - one feature/fix per PR

### During Development

1. **Write clear commit messages** (see [Commit Message Format](#commit-message-format))
2. **Keep commits atomic** - each commit should be a logical unit
3. **Test your changes** thoroughly
4. **Update documentation** for any user-facing changes
5. **Follow coding standards** (see [Coding Standards](#coding-standards))

### After Development

1. **Run all tests** to ensure nothing breaks
2. **Update CHANGELOG** if applicable
3. **Create a pull request** with a clear description
4. **Respond to feedback** promptly and respectfully

## 🔄 Pull Request Process

### 1. Prepare Your PR

- ✅ All tests pass
- ✅ Code follows project standards
- ✅ Documentation is updated
- ✅ No merge conflicts with main branch
- ✅ Commits are clean and well-organized

### 2. Create PR

Use this template for your PR description:

```markdown
## Description
[Brief description of what this PR does]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Performance improvement
- [ ] Test improvement

## Changes Made
- [List specific changes]
- [With bullet points]

## Testing
- [ ] All existing tests pass
- [ ] Added new tests for new functionality
- [ ] Manually tested the changes

## Documentation
- [ ] Updated relevant documentation
- [ ] Added code comments where necessary
- [ ] Updated CHANGELOG.md (if applicable)

## Related Issues
Fixes #[issue number]
Related to #[issue number]

## Screenshots (if applicable)
[Add screenshots for UI changes or data model changes]
```

### 3. Review Process

- Maintainers will review your PR
- Address any requested changes
- Once approved, your PR will be merged
- Your contribution will be credited

## 💻 Coding Standards

### SQL Style Guide (dbt Models)

```sql
-- Good example
WITH base_data AS (
    SELECT
        -- Keys
        country_code,
        date_key,
        
        -- Measures
        new_cases,
        new_deaths
    FROM {{ ref('source_table') }}
    WHERE date_key >= '2020-01-01'
        AND country_code IS NOT NULL
),

calculated AS (
    SELECT
        *,
        new_deaths::FLOAT / NULLIF(new_cases, 0) * 100 as case_fatality_rate
    FROM base_data
)

SELECT * FROM calculated
```

**Key Points**:
- Lowercase SQL keywords
- 4-space indentation
- Clear column grouping
- Meaningful CTEs
- Handle NULL values
- Use `{{ ref() }}` for model dependencies
- Add comments for complex logic

### Python Style Guide

- Follow PEP 8
- Use meaningful variable names
- Add docstrings for functions
- Keep functions focused and small
- Use type hints where appropriate

### dbt Model Naming

- **Staging**: `stg_{source}__{table}`
- **Bronze**: `brz__{table}`
- **Silver**: `slv_{entity}`
- **Gold Facts**: `fact_{entity}`
- **Gold Dimensions**: `dim_{entity}`
- **ML Models**: `ml_{purpose}`

## 🧪 Testing Requirements

### dbt Tests

All new models must include:

1. **Schema tests** in YAML:
   ```yaml
   models:
     - name: new_model
       columns:
         - name: id
           tests:
             - not_null
             - unique
         - name: foreign_key
           tests:
             - relationships:
                 to: ref('parent_model')
                 field: id
   ```

2. **Custom tests** if needed (in `tests/` directory)

3. **Documentation** in schema.yml

### Running Tests

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select new_model

# Run specific test type
dbt test --select test_type:unique
```

### Test Coverage

Aim for:
- 100% coverage of primary keys (unique + not_null)
- Foreign key relationship tests
- Business rule validation where applicable

## 📖 Documentation

### Required Documentation

When adding new features:

1. **Code comments** for complex logic
2. **Model descriptions** in schema.yml
3. **Column descriptions** for important fields
4. **Update relevant docs** (ARCHITECTURE.md, DATA_MODEL.md, etc.)
5. **Add examples** if introducing new patterns

### Documentation Standards

- Use clear, concise language
- Include code examples
- Add diagrams where helpful (text-based is fine)
- Keep it up-to-date with code changes

## 📜 Commit Message Format

Use conventional commit format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:
```bash
feat(gold): Add fact_vaccination model
fix(silver): Handle null values in slv_covid_daily
docs(setup): Update PostgreSQL installation instructions
test(bronze): Add tests for brz__new_cases_7day_avg
refactor(staging): Simplify staging layer queries
```

## 🎯 Good First Issues

Looking for a place to start? Check issues labeled:
- `good first issue`: Good for newcomers
- `help wanted`: We need help with these
- `documentation`: Documentation improvements

## 💬 Getting Help

Need help with your contribution?

1. **Read the docs**: Check [docs/](docs/) folder
2. **Ask questions**: Open a discussion or comment on the issue
3. **Review examples**: Look at existing PRs and code
4. **Be specific**: Provide context, error messages, and what you've tried

## 🏆 Recognition

Contributors are recognized in:
- GitHub contributors list
- Release notes
- Project documentation

Thank you for contributing to Pandemic Insights! 🎉

## 📞 Contact

- **Issues**: [GitHub Issues](https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/issues)
- **Discussions**: [GitHub Discussions](https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/discussions)

---

By contributing, you agree that your contributions will be licensed under the same license as the project.
