# Gaming Analytics Data Schema

## Overview
This document defines the data schema for our gaming analytics platform.

## Data Sources

### 1. Player Events
User interactions and game events.

**Fields:**
- event_id: UUID (Primary Key)
- player_id: UUID
- event_type: STRING (login, logout, level_start, level_complete, purchase, achievement)
- event_timestamp: TIMESTAMP
- game_version: STRING
- platform: STRING (iOS, Android, Web)
- country: STRING
- session_id: UUID
- level_id: INTEGER (nullable)
- achievement_id: INTEGER (nullable)

### 2. In-App Purchases
Transaction data for in-game purchases.

**Fields:**
- transaction_id: UUID (Primary Key)
- player_id: UUID
- purchase_timestamp: TIMESTAMP
- product_id: STRING
- product_name: STRING
- product_category: STRING (currency, powerup, cosmetic)
- amount: DECIMAL(10,2)
- currency: STRING (USD, EUR, TRY)
- payment_method: STRING
- platform: STRING
- country: STRING
- session_id: UUID

### 3. Player Demographics
Player profile information.

**Fields:**
- player_id: UUID (Primary Key)
- registration_date: DATE
- country: STRING
- age_group: STRING (13-17, 18-24, 25-34, 35-44, 45+)
- gender: STRING (M, F, O, Unknown)
- preferred_platform: STRING
- account_status: STRING (active, inactive, banned)
- last_login: TIMESTAMP

## Data Quality Considerations

- Duplicate events (same event_id)
- Late-arriving data (events arriving hours/days late)
- Missing values (null player_id, null timestamps)
- Invalid values (negative amounts, future timestamps)
- Orphaned records (purchases without player_id in demographics)

These issues are intentionally included for testing data quality frameworks.
