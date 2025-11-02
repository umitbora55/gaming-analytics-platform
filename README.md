# Gaming Analytics Data Platform

A production-ready, end-to-end data engineering project demonstrating modern data stack practices for gaming analytics.

## Project Overview

This project implements a complete data pipeline for a gaming analytics platform, processing player events, in-app purchases, and generating business insights using industry-standard tools and best practices.

## Architecture
```
Data Sources (CSV) → Airflow → PostgreSQL (Bronze)
                        ↓
                    DBT Transform
                        ↓
              Bronze → Silver → Gold
                        ↓
                Business Metrics
```

**Data Flow:**
1. Synthetic gaming data generation
2. Raw data ingestion to Bronze layer
3. DBT transformations (staging → marts → metrics)
4. Data quality validation (21 automated tests)
5. Business metrics in Gold layer

## Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Orchestration** | Apache Airflow 2.7.3 | Workflow management |
| **Transformation** | DBT 1.7.4 | Data modeling & testing |
| **Data Warehouse** | PostgreSQL 15 | Storage & analytics |
| **Containerization** | Docker & Docker Compose | Environment consistency |
| **Language** | Python 3.11 | ETL scripts & data generation |
| **CI/CD** | GitHub Actions | Automated testing |
| **Notebooks** | JupyterLab | Data exploration |

## Data Model

### Bronze Layer (Raw Data)
- `player_demographics`: Player profiles (1K records)
- `player_events`: Gaming events (50K records)
- `purchases`: Transaction data (5K records)

### Silver Layer (Cleaned & Modeled)
- `dim_players`: Player dimension with aggregated metrics
- `fact_events`: Event fact table with flags
- `fact_purchases`: Purchase fact table with USD conversion

### Gold Layer (Business Metrics)
- `daily_player_metrics`: DAU, ARPU, ARPPU, conversion rates
- `revenue_by_category`: Product performance breakdown
- `player_cohort_retention`: Retention analysis

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Git
- 8GB RAM minimum

### Installation

**1. Clone the repository**
```bash
git clone <your-repo-url>
cd gaming-analytics-platform
```

**2. Set environment variables**
```bash
echo "AIRFLOW_UID=$(id -u)" > .env
```

**3. Start services**
```bash
docker-compose up -d
```

**4. Access services**
- Airflow UI: http://localhost:8084 (airflow/airflow)
- JupyterLab: http://localhost:8888
- Warehouse DB: localhost:5437

**5. Setup DBT profiles**
```bash
docker-compose exec airflow-webserver mkdir -p /home/airflow/.dbt
docker-compose exec airflow-scheduler mkdir -p /home/airflow/.dbt

docker-compose exec airflow-webserver bash -c 'cat > /home/airflow/.dbt/profiles.yml << PROF
gaming_dbt:
  outputs:
    dev:
      type: postgres
      host: warehouse
      port: 5432
      user: warehouse
      password: warehouse
      dbname: gaming_dwh
      schema: silver
      threads: 4
  target: dev
PROF'

docker-compose exec airflow-scheduler bash -c 'cat > /home/airflow/.dbt/profiles.yml << PROF
gaming_dbt:
  outputs:
    dev:
      type: postgres
      host: warehouse
      port: 5432
      user: warehouse
      password: warehouse
      dbname: gaming_dwh
      schema: silver
      threads: 4
  target: dev
PROF'
```

**6. Trigger the pipeline**
```bash
docker-compose exec airflow-webserver airflow dags unpause gaming_analytics_pipeline
docker-compose exec airflow-webserver airflow dags trigger gaming_analytics_pipeline
```

## Pipeline Flow

1. **Data Generation** (5 sec) - Synthetic gaming data with intentional quality issues
2. **Data Ingestion** (7 sec) - Load CSV to PostgreSQL bronze layer
3. **DBT Transformations** (30 sec) - 9 models executed in dependency order
4. **Data Quality Tests** (10 sec) - 21 automated tests
5. **Documentation** (3 sec) - Auto-generated data catalog

**Total Runtime:** ~1 minute

## Testing

### Run DBT Tests
```bash
docker-compose exec airflow-webserver bash -c "cd /opt/airflow/gaming_dbt && dbt test"
```

### View Test Results
All 21 tests should pass:
- Source uniqueness & null checks
- Referential integrity (foreign keys)
- Value range validations
- Business rule assertions

## Key Metrics Generated

- **DAU (Daily Active Users)**: 780-830 users/day
- **Conversion Rate**: 17-21%
- **ARPU (Average Revenue Per User)**: $5.90-$9.21
- **ARPPU (Average Revenue Per Paying User)**: $30-$44
- **Retention Rates**: Day 1, 7, 30 cohorts

## Learning Outcomes

This project demonstrates:

**Data Engineering Best Practices**
- Medallion architecture (Bronze/Silver/Gold)
- Idempotent pipeline design
- Error handling & retries

**Modern Data Stack**
- ELT over ETL
- SQL-based transformations
- Version-controlled data models

**Data Quality**
- Automated testing framework
- Schema validation
- Business rule enforcement

**DevOps Practices**
- Containerization
- CI/CD automation
- Infrastructure as code

**Production Readiness**
- Monitoring & logging
- Dependency management
- Comprehensive documentation

## Project Structure
```
gaming-analytics-platform/
├── dags/                          # Airflow DAGs
│   └── gaming_analytics_pipeline.py
├── dbt_project/gaming_dbt/        # DBT project
│   ├── models/
│   │   ├── staging/              # Bronze to Staging
│   │   ├── marts/                # Silver layer
│   │   └── metrics/              # Gold layer
│   ├── tests/                    # Custom tests
│   └── dbt_project.yml
├── scripts/                       # Utility scripts
│   ├── generate_gaming_data.py
│   └── load_data_to_warehouse.py
├── notebooks/                     # Jupyter notebooks
│   └── 01_data_exploration.ipynb
├── data/                          # Data storage
│   ├── raw/
│   └── processed/
├── docs/                          # Documentation
├── .github/workflows/             # CI/CD
│   └── dbt_ci.yml
├── docker-compose.yml
├── Dockerfile
└── README.md
```

## Configuration

### Airflow
- Scheduler runs daily at 2 AM
- 2 retries with 5 minute delay
- LocalExecutor for simplicity

### DBT
- 9 models (3 staging, 3 marts, 3 metrics)
- 21 automated tests
- 4 parallel threads

### Database
- Bronze: Raw data
- Silver: Cleaned & modeled (default target)
- Gold: Business metrics

## Troubleshooting

### Pipeline Fails
```bash
# Check Airflow logs
docker-compose logs airflow-scheduler

# Check DBT logs
docker-compose exec airflow-webserver bash -c "cd /opt/airflow/gaming_dbt && dbt run --debug"
```

### Permission Issues
```bash
# Fix permissions
chmod -R 755 dags/ logs/ plugins/
```

### Database Connection Issues
```bash
# Test warehouse connection
docker-compose exec warehouse psql -U warehouse -d gaming_dwh -c "SELECT 1"
```

### DBT Profile Missing
If you see "Path '/home/airflow/.dbt' does not exist", re-run step 5 of installation.

## Interview Talking Points

**Technical Depth:**
- "Implemented medallion architecture with incremental transformations"
- "Built data quality framework with 21 automated tests"
- "Orchestrated end-to-end pipeline with Airflow and DBT"

**Business Impact:**
- "Generated key gaming metrics: DAU, ARPU, retention cohorts"
- "Identified data quality issues: 2% duplicates, 0.5% future timestamps"
- "Pipeline processes 56K records in under 1 minute"

**Best Practices:**
- "Containerized entire stack for reproducibility"
- "Implemented CI/CD with GitHub Actions"
- "Version-controlled data models and transformations"


## Additional Resources

- [DBT Documentation](https://docs.getdbt.com/)
- [Airflow Documentation](https://airflow.apache.org/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## Contributing

This is a portfolio project. Feel free to fork and adapt for your own use.

## License

MIT License

## Author

**Ümit Bora Günaydın**

Data Engineer | Building modern data pipelines

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/ümit-bora-günaydın/)

**Contact:** https://www.linkedin.com/in/ümit-bora-günaydın/

---

**Last Updated:** November 2025
