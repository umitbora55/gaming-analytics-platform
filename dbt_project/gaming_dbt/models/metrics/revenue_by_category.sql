-- Revenue breakdown by product category
-- Grain: One row per date per category

SELECT
    purchase_date AS date,
    product_category,
    COUNT(DISTINCT player_id) AS unique_buyers,
    COUNT(*) AS total_transactions,
    SUM(amount_usd) AS revenue_usd,
    AVG(amount_usd) AS avg_transaction_value,
    MIN(amount_usd) AS min_transaction_value,
    MAX(amount_usd) AS max_transaction_value,
    
    CURRENT_TIMESTAMP AS updated_at
FROM {{ ref('fact_purchases') }}
GROUP BY purchase_date, product_category
ORDER BY purchase_date, product_category
