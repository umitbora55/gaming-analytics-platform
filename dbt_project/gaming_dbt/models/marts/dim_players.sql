-- Dimension table for players
-- SCD Type 1 (current state only)

WITH player_base AS (
    SELECT * FROM {{ ref('stg_player_demographics') }}
),

player_activity AS (
    SELECT
        player_id,
        MIN(event_timestamp) AS first_event_date,
        MAX(event_timestamp) AS last_event_date,
        COUNT(DISTINCT DATE(event_timestamp)) AS days_active,
        COUNT(*) AS total_events
    FROM {{ ref('stg_player_events') }}
    GROUP BY player_id
),

player_revenue AS (
    SELECT
        player_id,
        COUNT(*) AS total_purchases,
        SUM(amount) AS lifetime_revenue,
        AVG(amount) AS avg_purchase_amount,
        MIN(purchase_timestamp) AS first_purchase_date,
        MAX(purchase_timestamp) AS last_purchase_date
    FROM {{ ref('stg_purchases') }}
    GROUP BY player_id
),

final AS (
    SELECT
        p.player_id,
        p.registration_date,
        p.country,
        p.age_group,
        p.gender,
        p.preferred_platform,
        p.account_status,
        p.last_login,
        
        -- Activity metrics
        COALESCE(a.first_event_date, p.registration_date::timestamp) AS first_activity_date,
        COALESCE(a.last_event_date, p.last_login) AS last_activity_date,
        COALESCE(a.days_active, 0) AS days_active,
        COALESCE(a.total_events, 0) AS total_events,
        
        -- Revenue metrics
        COALESCE(r.total_purchases, 0) AS total_purchases,
        COALESCE(r.lifetime_revenue, 0) AS lifetime_revenue,
        COALESCE(r.avg_purchase_amount, 0) AS avg_purchase_amount,
        r.first_purchase_date,
        r.last_purchase_date,
        
        -- Flags
        CASE WHEN r.player_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_paying_user,
        
        CURRENT_TIMESTAMP AS updated_at
    FROM player_base p
    LEFT JOIN player_activity a ON p.player_id = a.player_id
    LEFT JOIN player_revenue r ON p.player_id = r.player_id
)

SELECT * FROM final
