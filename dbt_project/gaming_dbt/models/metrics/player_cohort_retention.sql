-- Player retention by registration cohort
-- Grain: One row per cohort per days_since_registration

WITH player_registration AS (
    SELECT
        player_id,
        DATE(registration_date) AS cohort_date
    FROM {{ ref('dim_players') }}
),

player_daily_activity AS (
    SELECT DISTINCT
        player_id,
        event_date
    FROM {{ ref('fact_events') }}
),

cohort_activity AS (
    SELECT
        r.cohort_date,
        a.event_date,
        a.event_date - r.cohort_date AS days_since_registration,
        COUNT(DISTINCT a.player_id) AS active_users
    FROM player_registration r
    INNER JOIN player_daily_activity a ON r.player_id = a.player_id
    GROUP BY r.cohort_date, a.event_date
),

cohort_size AS (
    SELECT
        cohort_date,
        COUNT(*) AS cohort_size
    FROM player_registration
    GROUP BY cohort_date
),

final AS (
    SELECT
        ca.cohort_date,
        cs.cohort_size,
        ca.event_date,
        ca.days_since_registration,
        ca.active_users,
        ROUND((ca.active_users::NUMERIC / cs.cohort_size) * 100, 2) AS retention_rate_pct,
        
        CURRENT_TIMESTAMP AS updated_at
    FROM cohort_activity ca
    INNER JOIN cohort_size cs ON ca.cohort_date = cs.cohort_date
)

SELECT * FROM final
WHERE days_since_registration BETWEEN 0 AND 30  -- First 30 days
ORDER BY cohort_date, days_since_registration
