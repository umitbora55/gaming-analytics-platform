"""
Load CSV data into warehouse bronze tables
"""
import pandas as pd
from sqlalchemy import create_engine
import sys

# Database connection
DB_CONN = "postgresql://warehouse:warehouse@warehouse:5432/gaming_dwh"

def load_data():
    """Load all CSV files into bronze tables"""
    
    print("Connecting to warehouse...")
    engine = create_engine(DB_CONN)
    
    # Load players
    print("\n1. Loading player_demographics...")
    players_df = pd.read_csv('/opt/airflow/data/raw/player_demographics.csv')
    players_df.to_sql('player_demographics', engine, schema='bronze', 
                      if_exists='append', index=False)
    print(f"   Loaded {len(players_df):,} records")
    
    # Load events - remove duplicates
    print("\n2. Loading player_events...")
    events_df = pd.read_csv('/opt/airflow/data/raw/player_events.csv')
    original_count = len(events_df)
    events_df = events_df.drop_duplicates(subset=['event_id'], keep='first')
    print(f"   Removed {original_count - len(events_df):,} duplicate events")
    events_df.to_sql('player_events', engine, schema='bronze',
                     if_exists='append', index=False)
    print(f"   Loaded {len(events_df):,} records")
    
    # Load purchases
    print("\n3. Loading purchases...")
    purchases_df = pd.read_csv('/opt/airflow/data/raw/purchases.csv')
    purchases_df.to_sql('purchases', engine, schema='bronze',
                        if_exists='append', index=False)
    print(f"   Loaded {len(purchases_df):,} records")
    
    print("\n" + "="*50)
    print("DATA LOAD COMPLETE!")
    print("="*50)

if __name__ == "__main__":
    load_data()
