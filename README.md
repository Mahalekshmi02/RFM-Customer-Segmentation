#  RFM Sales Analysis & Customer Segmentation
**Tools:** SQL (PostgreSQL), Power BI, Excel

## 📌 Project Overview
I analyzed a dataset of **1 million+ retail transactions** to perform an **RFM (Recency, Frequency, Monetary)** analysis. The goal was to segment customers based on purchasing behavior and identify high-value "Champions" versus "At Risk" customers.

![Dashboard Preview](dashboard.jpg)
*(My Power BI Dashboard visualizing the segments)*

## 📂 Data Source
The raw, uncleaned dataset used for this analysis is available here: [Raw File.zip](Raw%20File.zip)
*(Note: This file contains nulls, returns, and negative values which were cleaned using SQL)*


## 🔍 Key Insights
- **The "Champions" (Top 20%) drive 60% of revenue.** Despite representing a small portion of the user base, this segment is critical to profitability.
- **Unexpected Product Driver:** The top-selling item for VIPs is NOT a luxury item, but low-cost decorative hardware (Avg Price < $5), suggesting a B2B or "craft-store" user base.
- **Retention Opportunity:** The largest segment is **"Potential Loyalists"**. Converting just 10% of this group could increase revenue by roughly 15%.

## 💡 Business Recommendations
Based on the analysis, I recommend the following actions:
1. **Target the "At Risk" Champions:** The dashboard identifies 1,200+ customers who spend highly but haven't purchased recently. The sales team should prioritize calling these clients immediately.
2. **Cross-Sell to "Potential Loyalists":** This segment is large and active. Offering them a small discount or bundle deal could push them into the "Loyal" or "Champion" tier.
3. **Re-evaluate Product Mix:** Since top customers buy low-cost items frequently, stock levels for these "bread and butter" items should be increased to prevent stockouts.

## 🛠️ Technical Process
1. **Data Engineering:**
   - Imported raw CSV data into **PostgreSQL**.
   - Handled data quality issues: Removed records with null Customer IDs and negative quantity values (returns).

2. **Analysis (SQL):**
   - Calculated **Recency, Frequency, and Monetary** metrics for each customer.
   - Used `NTILE(5)` window functions to score customers on a 1-5 scale.
   - Used **CTEs** (Common Table Expressions) to keep the code modular and clean.

3. **Visualization (Power BI):**
   - Built an interactive dashboard to filter customers by segment.
   - Created specific "Call Lists" for the sales team to target "At Risk" high-spenders.

## 📄 SQL Code Structure
You can view the full SQL script in the file [rfm_analysis.sql](rfm_analysis.sql).
The logic follows this flow:
1. `CREATE TABLE` and Import data.
2. `WITH rfm_metrics AS (...)` -> Calculate raw metrics.
3. `WITH rfm_scores AS (...)` -> Score customers 1-5.
4. `SELECT ... CASE WHEN ...` -> Assign segments (Champions, Loyal, etc.).
