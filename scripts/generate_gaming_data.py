"""
Gaming Analytics Data Generator

Generates realistic synthetic data for:
- Player events
- In-app purchases  
- Player demographics

Includes intentional data quality issues for testing.
"""

import pandas as pd
import numpy as np
from faker import Faker
from datetime import datetime, timedelta
import uuid
import random
import os

# Initialize Faker
fake = Faker()
Faker.seed(42)
np.random.seed(42)
random.seed(42)

# Configuration
NUM_PLAYERS = 1000
NUM_EVENTS = 50000
NUM_PURCHASES = 5000
START_DATE = datetime(2024, 10, 1)
END_DATE = datetime(2024, 10, 31)

# Constants
PLATFORMS = ['iOS', 'Android', 'Web']
COUNTRIES = ['US', 'TR', 'GB', 'DE', 'FR', 'JP', 'BR', 'IN']
EVENT_TYPES = ['login', 'logout', 'level_start', 'level_complete', 'purchase', 'achievement']
PRODUCT_CATEGORIES = ['currency', 'powerup', 'cosmetic']
CURRENCIES = ['USD', 'EUR', 'TRY']
PAYMENT_METHODS = ['credit_card', 'paypal', 'google_pay', 'apple_pay']
AGE_GROUPS = ['13-17', '18-24', '25-34', '35-44', '45+']
GENDERS = ['M', 'F', 'O', 'Unknown']
ACCOUNT_STATUSES = ['active', 'inactive', 'banned']


def generate_player_demographics(num_players):
    """Generate player demographics data"""
    print(f"Generating {num_players} player records...")
    
    players = []
    for _ in range(num_players):
        player_id = str(uuid.uuid4())
        reg_date = fake.date_between(start_date='-2y', end_date=START_DATE)
        
        player = {
            'player_id': player_id,
            'registration_date': reg_date,
            'country': random.choice(COUNTRIES),
            'age_group': random.choice(AGE_GROUPS),
            'gender': random.choice(GENDERS),
            'preferred_platform': random.choice(PLATFORMS),
            'account_status': np.random.choice(
                ACCOUNT_STATUSES, 
                p=[0.85, 0.10, 0.05]
            ),
            'last_login': fake.date_time_between(
                start_date=reg_date,
                end_date=END_DATE
            )
        }
        players.append(player)
    
    df = pd.DataFrame(players)
    
    # Introduce data quality issues (5% missing countries)
    missing_idx = df.sample(frac=0.05).index
    df.loc[missing_idx, 'country'] = None
    
    return df


def generate_player_events(player_ids, num_events):
    """Generate player events data"""
    print(f"Generating {num_events} event records...")
    
    events = []
    for _ in range(num_events):
        event_type = random.choice(EVENT_TYPES)
        event_timestamp = fake.date_time_between(
            start_date=START_DATE,
            end_date=END_DATE
        )
        
        event = {
            'event_id': str(uuid.uuid4()),
            'player_id': random.choice(player_ids),
            'event_type': event_type,
            'event_timestamp': event_timestamp,
            'game_version': f"1.{random.randint(0, 5)}.{random.randint(0, 10)}",
            'platform': random.choice(PLATFORMS),
            'country': random.choice(COUNTRIES),
            'session_id': str(uuid.uuid4()),
            'level_id': random.randint(1, 100) if event_type in ['level_start', 'level_complete'] else None,
            'achievement_id': random.randint(1, 50) if event_type == 'achievement' else None
        }
        events.append(event)
    
    df = pd.DataFrame(events)
    
    # Data quality issues
    # 1. Duplicate events (2%)
    duplicate_count = int(len(df) * 0.02)
    duplicates = df.sample(n=duplicate_count)
    df = pd.concat([df, duplicates], ignore_index=True)
    
    # 2. Missing player_ids (1%)
    missing_idx = df.sample(frac=0.01).index
    df.loc[missing_idx, 'player_id'] = None
    
    # 3. Future timestamps (0.5%)
    future_idx = df.sample(frac=0.005).index
    df.loc[future_idx, 'event_timestamp'] = df.loc[future_idx, 'event_timestamp'] + timedelta(days=365)
    
    return df


def generate_purchases(player_ids, num_purchases):
    """Generate in-app purchase data"""
    print(f"Generating {num_purchases} purchase records...")
    
    purchases = []
    for _ in range(num_purchases):
        product_category = random.choice(PRODUCT_CATEGORIES)
        
        purchase = {
            'transaction_id': str(uuid.uuid4()),
            'player_id': random.choice(player_ids),
            'purchase_timestamp': fake.date_time_between(
                start_date=START_DATE,
                end_date=END_DATE
            ),
            'product_id': f"PROD_{random.randint(1000, 9999)}",
            'product_name': f"{product_category.title()} Pack {random.randint(1, 10)}",
            'product_category': product_category,
            'amount': round(random.uniform(0.99, 99.99), 2),
            'currency': random.choice(CURRENCIES),
            'payment_method': random.choice(PAYMENT_METHODS),
            'platform': random.choice(PLATFORMS),
            'country': random.choice(COUNTRIES),
            'session_id': str(uuid.uuid4())
        }
        purchases.append(purchase)
    
    df = pd.DataFrame(purchases)
    
    # Data quality issues
    # 1. Negative amounts (0.5%)
    negative_idx = df.sample(frac=0.005).index
    df.loc[negative_idx, 'amount'] = -df.loc[negative_idx, 'amount']
    
    # 2. Orphaned player_ids (add some non-existent players, 2%)
    orphan_idx = df.sample(frac=0.02).index
    df.loc[orphan_idx, 'player_id'] = [str(uuid.uuid4()) for _ in range(len(orphan_idx))]
    
    return df


def main():
    """Main execution function"""
    print("=" * 50)
    print("Gaming Analytics Data Generator")
    print("=" * 50)
    
    # Create output directory
    output_dir = '/opt/airflow/data/raw'
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate data
    print("\n1. Generating Player Demographics...")
    players_df = generate_player_demographics(NUM_PLAYERS)
    player_ids = players_df['player_id'].tolist()
    
    print("\n2. Generating Player Events...")
    events_df = generate_player_events(player_ids, NUM_EVENTS)
    
    print("\n3. Generating In-App Purchases...")
    purchases_df = generate_purchases(player_ids, NUM_PURCHASES)
    
    # Save to CSV
    print("\n4. Saving to CSV files...")
    players_df.to_csv(f'{output_dir}/player_demographics.csv', index=False)
    events_df.to_csv(f'{output_dir}/player_events.csv', index=False)
    purchases_df.to_csv(f'{output_dir}/purchases.csv', index=False)
    
    # Summary
    print("\n" + "=" * 50)
    print("DATA GENERATION SUMMARY")
    print("=" * 50)
    print(f"Players: {len(players_df):,} records")
    print(f"Events: {len(events_df):,} records")
    print(f"Purchases: {len(purchases_df):,} records")
    print(f"\nFiles saved to: {output_dir}")
    print("=" * 50)


if __name__ == "__main__":
    main()
