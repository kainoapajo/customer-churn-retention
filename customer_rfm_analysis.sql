-- Query: RFM Segmentation and Churn Risk Calculation
-- Author: Kainoa Pajo

WITH rfm_base AS (
    SELECT 
        customer_id,
        MAX(transaction_date) AS last_purchase_date,
        COUNT(order_id) AS frequency,
        SUM(order_total) AS monetary_value,
        DATEDIFF('day', MAX(transaction_date), CURRENT_DATE) AS recency
    FROM 
        transactions
    GROUP BY 
        customer_id
),

rfm_scores AS (
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary_value,
        -- Window Functions to score customers from 1 (Low) to 4 (High)
        NTILE(4) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary_value ASC) AS m_score
    FROM 
        rfm_base
)

SELECT 
    customer_id,
    (r_score + f_score + m_score) AS total_rfm_score,
    CASE 
        WHEN (r_score + f_score + m_score) >= 10 THEN 'High Value - Retain'
        WHEN (r_score + f_score + m_score) <= 4 THEN 'At Risk - Churn Likely'
        ELSE 'Standard Customer'
    END AS customer_segment
FROM 
    rfm_scores
ORDER BY 
    total_rfm_score DESC;