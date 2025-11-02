-- Fact table for player events
-- Grain: One row per event

SELECT
    event_id,
    player_id,
    event_type,
    event_timestamp,
    DATE(event_timestamp) AS event_date,
    game_version,
    platform,
    country,
    session_id,
    level_id,
    achievement_id,
    
    -- Event type flags for easy filtering
    CASE WHEN event_type = 'login' THEN 1 ELSE 0 END AS is_login,
    CASE WHEN event_type = 'logout' THEN 1 ELSE 0 END AS is_logout,
    CASE WHEN event_type = 'level_start' THEN 1 ELSE 0 END AS is_level_start,
    CASE WHEN event_type = 'level_complete' THEN 1 ELSE 0 END AS is_level_complete,
    CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END AS is_purchase_event,
    CASE WHEN event_type = 'achievement' THEN 1 ELSE 0 END AS is_achievement,
    
    loaded_at
FROM {{ ref('stg_player_events') }}
