-- Gaming Analytics Data Warehouse Schema
-- Creates Bronze, Silver, and Gold layers

-- Bronze Layer (Raw data ingestion)
CREATE SCHEMA IF NOT EXISTS bronze;

-- Silver Layer (Cleaned and transformed)
CREATE SCHEMA IF NOT EXISTS silver;

-- Gold Layer (Business metrics and aggregations)
CREATE SCHEMA IF NOT EXISTS gold;

-- Raw staging tables in Bronze
CREATE TABLE IF NOT EXISTS bronze.player_demographics (
    player_id VARCHAR(36) PRIMARY KEY,
    registration_date DATE,
    country VARCHAR(10),
    age_group VARCHAR(10),
    gender VARCHAR(10),
    preferred_platform VARCHAR(20),
    account_status VARCHAR(20),
    last_login TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze.player_events (
    event_id VARCHAR(36) PRIMARY KEY,
    player_id VARCHAR(36),
    event_type VARCHAR(50),
    event_timestamp TIMESTAMP,
    game_version VARCHAR(20),
    platform VARCHAR(20),
    country VARCHAR(10),
    session_id VARCHAR(36),
    level_id INTEGER,
    achievement_id INTEGER,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze.purchases (
    transaction_id VARCHAR(36) PRIMARY KEY,
    player_id VARCHAR(36),
    purchase_timestamp TIMESTAMP,
    product_id VARCHAR(50),
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    amount DECIMAL(10,2),
    currency VARCHAR(3),
    payment_method VARCHAR(50),
    platform VARCHAR(20),
    country VARCHAR(10),
    session_id VARCHAR(36),
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
