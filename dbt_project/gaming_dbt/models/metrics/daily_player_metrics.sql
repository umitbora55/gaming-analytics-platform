-- Daily player engagement metrics
-- Grain: One row per date

WITH daily_events AS (
    SELECT
        event_date,
        COUNT(DISTINCT player_id) AS daily_active_users,
        COUNT(DISTINCT session_id) AS total_sessions,
        COUNT(*) AS total_events,
        SUM(is_login) AS total_logins,
        SUM(is_level_complete) AS total_level_completions,
        SUM(is_achievement) AS total_achievements
    FROM {{ ref('fact_events') }}
    GROUP BY event_date
),

daily_purchases AS (
    SELECT
        purchase_date,
        COUNT(DISTINCT player_id) AS paying_users,
        COUNT(*) AS total_transactions,
        SUM(amount_usd) AS daily_revenue
    FROM {{ ref('fact_purchases') }}
    GROUP BY purchase_date
),

final AS (
    SELECT
        e.event_date AS date,
        e.daily_active_users,
        e.total_sessions,
        e.total_events,
        e.total_logins,
        e.total_level_completions,
        e.total_achievements,
        
        COALESCE(p.paying_users, 0) AS paying_users,
        COALESCE(p.total_transactions, 0) AS total_transactions,
        COALESCE(p.daily_revenue, 0) AS daily_revenue,
        
        -- Calculated metrics
        ROUND(e.total_events::NUMERIC / e.daily_active_users, 2) AS avg_events_per_user,
        ROUND(e.total_sessions::NUMERIC / e.daily_active_users, 2) AS avg_sessions_per_user,
        CASE 
            WHEN e.daily_active_users > 0 
            THEN ROUND((COALESCE(p.paying_users, 0)::NUMERIC / e.daily_active_users) * 100, 2)
            ELSE 0 
        END AS conversion_rate_pct,
        CASE
            WHEN e.daily_active_users > 0
            THEN ROUND(COALESCE(p.daily_revenue, 0) / e.daily_active_users, 2)
            ELSE 0
        END AS arpu,
        CASE
            WHEN COALESCE(p.paying_users, 0) > 0
            THEN ROUND(COALESCE(p.daily_revenue, 0) / p.paying_users, 2)
            ELSE 0
        END AS arppu,
        
        CURRENT_TIMESTAMP AS updated_at
    FROM daily_events e
    LEFT JOIN daily_purchases p ON e.event_date = p.purchase_date
)

SELECT * FROM final
ORDER BY date
