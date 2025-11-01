# Gaming Analytics Data Platform

A production-ready, end-to-end data engineering project showcasing modern data stack practices.

## Project Overview

This project simulates a real-world gaming analytics platform that processes player events, in-app purchases, and game sessions to generate business insights.

## Tech Stack

- **Orchestration**: Apache Airflow
- **Transformation**: DBT (Data Build Tool)
- **Data Warehouse**: PostgreSQL (simulating BigQuery)
- **Language**: Python 3.11
- **Containerization**: Docker & Docker Compose
- **CI/CD**: GitHub Actions
- **Data Quality**: DBT Tests + Great Expectations

## Architecture
```
Data Sources (Synthetic) → Airflow → PostgreSQL (Raw)
                              ↓
                         DBT Transform
                              ↓
                    Bronze → Silver → Gold
                              ↓
                      Analytics Layer
```

## Project Structure
```
gaming-analytics-platform/
├── dags/                   # Airflow DAGs
├── dbt_project/            # DBT models and tests
├── data/
│   ├── raw/               # Raw data files
│   └── processed/         # Processed data
├── scripts/               # Utility scripts (data generation)
├── plugins/               # Airflow plugins
├── tests/                 # Integration tests
├── docs/                  # Documentation
└── logs/                  # Application logs
```

## Getting Started

Documentation will be added as the project develops.

## Project Phases

- [ ] Phase 1: Project Setup & Infrastructure
- [ ] Phase 2: Data Source & Ingestion
- [ ] Phase 3: DBT Setup & Bronze Layer
- [ ] Phase 4: Silver & Gold Layers
- [ ] Phase 5: Data Quality & Testing
- [ ] Phase 6: Orchestration & Scheduling
- [ ] Phase 7: CI/CD & Deployment
- [ ] Phase 8: Cost Optimization

## Author

Data Engineering Portfolio Project
