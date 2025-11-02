-- Test: Events should be within reasonable date range
-- Catches data generation bugs (future dates)

SELECT
    event_id,
    event_timestamp
FROM {{ ref('fact_events') }}
WHERE 
    event_timestamp > CURRENT_TIMESTAMP
    OR event_timestamp < '2020-01-01'
