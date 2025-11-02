-- Test: Daily revenue should never be negative
-- This catches data quality issues in purchase amounts

SELECT
    date,
    daily_revenue
FROM {{ ref('daily_player_metrics') }}
WHERE daily_revenue < 0
