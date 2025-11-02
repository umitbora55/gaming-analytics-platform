-- Fact table for purchases
-- Grain: One row per transaction

SELECT
    transaction_id,
    player_id,
    purchase_timestamp,
    DATE(purchase_timestamp) AS purchase_date,
    product_id,
    product_name,
    product_category,
    amount,
    currency,
    payment_method,
    platform,
    country,
    session_id,
    
    -- Category flags
    CASE WHEN product_category = 'currency' THEN 1 ELSE 0 END AS is_currency_purchase,
    CASE WHEN product_category = 'powerup' THEN 1 ELSE 0 END AS is_powerup_purchase,
    CASE WHEN product_category = 'cosmetic' THEN 1 ELSE 0 END AS is_cosmetic_purchase,
    
    -- Amount in USD (simplified conversion, real case would use exchange rates)
    CASE 
        WHEN currency = 'USD' THEN amount
        WHEN currency = 'EUR' THEN amount * 1.1
        WHEN currency = 'TRY' THEN amount * 0.03
        ELSE amount
    END AS amount_usd,
    
    loaded_at
FROM {{ ref('stg_purchases') }}
