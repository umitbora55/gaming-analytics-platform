-- Staging model for player demographics
-- Cleans and standardizes raw player data

WITH source AS (
    SELECT * FROM {{ source('bronze', 'player_demographics') }}
),

cleaned AS (
    SELECT
        player_id,
        registration_date,
        COALESCE(country, 'UNKNOWN') AS country,  -- Handle missing countries
        age_group,
        gender,
        preferred_platform,
        account_status,
        last_login,
        loaded_at
    FROM source
    WHERE player_id IS NOT NULL  -- Remove records without player_id
)

SELECT * FROM cleaned
