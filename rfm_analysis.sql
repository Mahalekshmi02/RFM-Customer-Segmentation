--INSPECT DATA & HANDLE NULLS

WITH valid_transactions AS (
    SELECT 
        "InvoiceNo",
        "StockCode",
        "Description",
        "Quantity",
        "InvoiceDate",
        "UnitPrice",
        "CustomerID",
        "Country",
        -- Calculate Total Spend for each line item
        ("Quantity" * "UnitPrice") AS TotalSpend
    FROM public.online_retail
    WHERE "CustomerID" IS NOT NULL 
      AND "Quantity" > 0 
      AND "UnitPrice" > 0
),

-- CALCULATE RFM METRICS

rfm_base AS (
    SELECT 
        "CustomerID",
        -- Recency: Days since last purchase
        ('2011-12-10'::date - MAX("InvoiceDate")::date) AS Recency_Days,
        
        -- Frequency: Count of unique invoices (transactions)
        COUNT(DISTINCT "InvoiceNo") AS Frequency_Count,
        
        -- Monetary: Total money spent
        SUM(TotalSpend) AS Monetary_Value
    FROM valid_transactions
    GROUP BY "CustomerID"
),

-- CALCULATE RFM SCORES (1-5 SCALE)

rfm_scores AS (
    SELECT 
        "CustomerID",
        Recency_Days,
        Frequency_Count,
        Monetary_Value,
        NTILE(5) OVER (ORDER BY Recency_Days DESC) AS R_Score, -- 5 is most recent
        NTILE(5) OVER (ORDER BY Frequency_Count ASC) AS F_Score, -- 5 is most frequent
        NTILE(5) OVER (ORDER BY Monetary_Value ASC) AS M_Score -- 5 is highest spender
    FROM rfm_base
)

-- ASSIGN CUSTOMER SEGMENTS

SELECT 
    "CustomerID",
    Recency_Days,
    Frequency_Count,
    Monetary_Value,
    R_Score,
    F_Score,
    M_Score,
    -- Concatenate scores for easy reading (e.g., "555")
    CAST(R_Score AS varchar) || CAST(F_Score AS varchar) || CAST(M_Score AS varchar) AS RFM_Cell,
    
    -- Segmentation Logic
    CASE 
        WHEN R_Score = 5 AND F_Score = 5 THEN 'Champions'
        WHEN R_Score = 5 AND F_Score = 4 THEN 'Loyal Customers'
        WHEN R_Score = 4 AND F_Score = 5 THEN 'Loyal Customers'
        WHEN R_Score = 4 AND F_Score = 4 THEN 'Potential Loyalist'
        WHEN R_Score = 5 AND F_Score = 2 THEN 'Potential Loyalist'
        WHEN R_Score = 4 AND F_Score = 2 THEN 'Potential Loyalist'
        WHEN R_Score = 3 AND F_Score = 3 THEN 'Potential Loyalist'
        WHEN R_Score = 5 AND F_Score = 1 THEN 'Recent Customers'
        WHEN R_Score = 4 AND F_Score = 1 THEN 'Promising'
        WHEN R_Score = 3 AND F_Score = 1 THEN 'Promising'
        WHEN R_Score = 2 AND F_Score = 2 THEN 'Customers Needing Attention'
        WHEN R_Score = 2 AND F_Score = 1 THEN 'About to Sleep'
        WHEN R_Score = 1 AND F_Score = 5 THEN 'Can''t Lose Them'
        WHEN R_Score = 1 AND F_Score = 4 THEN 'Can''t Lose Them'
        WHEN R_Score = 1 AND F_Score = 2 THEN 'At Risk'
        WHEN R_Score = 1 AND F_Score = 1 THEN 'Lost Customers'
        ELSE 'Other'
    END AS Customer_Segment
FROM rfm_scores;
