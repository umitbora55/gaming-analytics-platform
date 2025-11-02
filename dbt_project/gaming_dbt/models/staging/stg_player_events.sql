-- Staging model for player events
-- Cleans and filters raw event data

WITH source AS (
    SELECT * FROM {{ source('bronze', 'player_events') }}
),

cleaned AS (
    SELECT
        event_id,
        player_id,
        event_type,
        event_timestamp,
        game_version,
        platform,
        COALESCE(country, 'UNKNOWN') AS country,
        session_id,
        level_id,
        achievement_id,
        loaded_at
    FROM source
    WHERE 
        event_id IS NOT NULL
        AND player_id IS NOT NULL
        AND event_timestamp <= CURRENT_TIMESTAMP  -- Remove future events
        AND event_timestamp >= '2024-01-01'  -- Sanity check on dates
)

SELECT * FROM cleaned
