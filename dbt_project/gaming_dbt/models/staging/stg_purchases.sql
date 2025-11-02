-- Staging model for purchases
-- Cleans purchase data and filters invalid transactions

WITH source AS (
    SELECT * FROM {{ source('bronze', 'purchases') }}
),

cleaned AS (
    SELECT
        transaction_id,
        player_id,
        purchase_timestamp,
        product_id,
        product_name,
        product_category,
        amount,
        currency,
        payment_method,
        platform,
        COALESCE(country, 'UNKNOWN') AS country,
        session_id,
        loaded_at
    FROM source
    WHERE 
        transaction_id IS NOT NULL
        AND player_id IS NOT NULL
        AND amount > 0  -- Remove negative/zero amounts
        AND purchase_timestamp <= CURRENT_TIMESTAMP
        AND purchase_timestamp >= '2024-01-01'
)

SELECT * FROM cleaned
