# Documentation Index

Welcome to the Pandemic Insights technical documentation. This index will help you navigate the documentation based on your needs.

## 📖 Documentation Overview

| Document | Purpose | Audience |
|----------|---------|----------|
| [SETUP.md](SETUP.md) | Installation and setup guide | New users, DevOps |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System architecture and design | Architects, Technical leads |
| [DATA_MODEL.md](DATA_MODEL.md) | Data model and schema details | Data engineers, Analysts |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Development workflow and best practices | Developers, Contributors |

## 🎯 Quick Navigation by Role

### For New Users
Start here to get the system running:
1. [SETUP.md](SETUP.md) - Follow the installation guide
2. [README.md](../README.md) - Understand the project overview
3. [DATA_MODEL.md](DATA_MODEL.md) - Learn about available data

### For Data Analysts
Working with the data:
1. [DATA_MODEL.md](DATA_MODEL.md) - Understand tables and schemas
2. Sample queries and use cases
3. How to access gold layer tables

### For Data Engineers
Building and maintaining pipelines:
1. [ARCHITECTURE.md](ARCHITECTURE.md) - Understand system design
2. [DEVELOPMENT.md](DEVELOPMENT.md) - Learn development workflow
3. [DATA_MODEL.md](DATA_MODEL.md) - Understand data lineage

### For DevOps Engineers
Deploying and maintaining infrastructure:
1. [SETUP.md](SETUP.md) - Installation and configuration
2. [ARCHITECTURE.md](ARCHITECTURE.md) - Deployment architecture
3. [DEVELOPMENT.md](DEVELOPMENT.md) - Monitoring and maintenance

### For Contributors
Contributing to the project:
1. [DEVELOPMENT.md](DEVELOPMENT.md) - Development guidelines and best practices
2. [ARCHITECTURE.md](ARCHITECTURE.md) - System design principles
3. [README.md](../README.md) - Contributing section

## 🔍 Quick Reference by Topic

### Installation & Setup
- [Prerequisites](SETUP.md#prerequisites)
- [Database Setup](SETUP.md#2-database-setup)
- [dbt Setup](SETUP.md#3-dbt-setup)
- [Airflow Setup](SETUP.md#4-airflow-setup-optional-but-recommended)
- [Troubleshooting](SETUP.md#troubleshooting)

### Architecture & Design
- [System Overview](ARCHITECTURE.md#system-overview)
- [Architecture Diagrams](ARCHITECTURE.md#architecture-diagram)
- [Component Architecture](ARCHITECTURE.md#component-architecture)
- [Technology Stack](ARCHITECTURE.md#technology-stack)
- [Data Flow](ARCHITECTURE.md#data-flow)
- [Design Principles](ARCHITECTURE.md#key-design-principles)

### Data Model
- [Data Sources](DATA_MODEL.md#data-sources)
- [Medallion Architecture](DATA_MODEL.md#medallion-architecture)
- [Staging Layer](DATA_MODEL.md#staging-layer)
- [Bronze Layer](DATA_MODEL.md#bronze-layer)
- [Silver Layer](DATA_MODEL.md#silver-layer)
- [Gold Layer](DATA_MODEL.md#gold-layer)
- [Fact Tables](DATA_MODEL.md#fact-tables)
- [Dimension Tables](DATA_MODEL.md#dimension-tables)
- [Data Lineage](DATA_MODEL.md#data-lineage)
- [Sample Queries](DATA_MODEL.md#querying-the-data)

### Development
- [Project Structure](DEVELOPMENT.md#project-structure)
- [Development Workflow](DEVELOPMENT.md#development-workflow)
- [dbt Commands](DEVELOPMENT.md#daily-development-commands)
- [Model Development](DEVELOPMENT.md#model-development-process)
- [Best Practices](DEVELOPMENT.md#best-practices)
- [Testing](DEVELOPMENT.md#testing)
- [Debugging](DEVELOPMENT.md#debugging)
- [Deployment](DEVELOPMENT.md#deployment)

## 📝 Document Summaries

### SETUP.md
Complete installation and configuration guide covering:
- Software prerequisites (Python, Google Cloud SDK, Docker)
- Step-by-step BigQuery dataset setup
- dbt installation and configuration
- Airflow deployment with Astronomer
- Troubleshooting common issues
- Verification steps

**When to read**: First time setup or when deploying to new environment

### ARCHITECTURE.md
System design and architecture documentation covering:
- High-level system overview
- Component architecture with diagrams
- Technology stack details
- Data flow through the system
- Medallion architecture explanation
- Design principles and patterns
- Security and scalability considerations
- Deployment architecture

**When to read**: When understanding system design or making architectural decisions

### DATA_MODEL.md
Data model and schema documentation covering:
- All data sources and raw files
- Medallion architecture layers (Staging → Bronze → Silver → Gold)
- Complete schema documentation for all tables
- Fact and dimension table details
- ML features table
- Data lineage and dependencies
- Sample analytical queries
- Schema evolution guide

**When to read**: When working with data, building reports, or creating new models

### DEVELOPMENT.md
Developer guide and best practices covering:
- Detailed project structure
- Daily development workflow
- dbt model development process
- SQL style guide
- Testing strategy
- Debugging techniques
- Deployment checklist
- Git workflow
- Code review guidelines
- Monitoring and maintenance

**When to read**: When developing new features or contributing code

## 🔗 External Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Astronomer Documentation](https://docs.astronomer.io/)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Project GitHub Repository](https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System)

## 📊 Documentation Statistics

- Total Documentation Files: 4
- Total Lines: ~1,900
- Topics Covered: 50+
- Code Examples: 100+
- Diagrams: Multiple text-based diagrams

## 🆘 Getting Help

If you can't find what you're looking for:

1. **Search the docs**: Use your browser's search (Ctrl+F / Cmd+F)
2. **Check the FAQ**: See [SETUP.md - Troubleshooting](SETUP.md#troubleshooting)
3. **Review examples**: See [DATA_MODEL.md - Sample Queries](DATA_MODEL.md#querying-the-data)
4. **Check logs**: See [DEVELOPMENT.md - Debugging](DEVELOPMENT.md#debugging)
5. **Ask the community**: Open a GitHub issue

## 📅 Document Maintenance

These documents are maintained alongside the codebase. When making changes:
- Update relevant documentation
- Keep examples current
- Verify all links work
- Update version numbers and dates

**Last Updated**: January 2026
**Documentation Version**: 1.0
