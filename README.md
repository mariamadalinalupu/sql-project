# Bike Store Sales Analysis (2016–2018)

## Overview
This project explores sales data from three U.S. bike stores over a 35-month period. The analysis identifies key sales drivers, trends, and seasonal patterns, and compares product and store performance. It demonstrates the use of SQL for data cleaning, analysis, aggregation, and insight generation.

## Dataset
The data was obtained from Kaggle and is a relational database containing eight tables.  
[Dataset link](https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database?resource=download)

## Goal / Questions
- Which product categories contribute most to total sales?  
- How have sales for each product category evolved year over year?  
- Are there any seasonal patterns or months that consistently show higher sales between 2016 and 2018?

## Methods
Key SQL techniques used: joins, CTEs, and window functions.

## Insights
- Products in the **Mountain Bikes** category contribute the most to overall sales (35%), followed by **Road Bikes** (21%) and **Cruiser Bicycles** (13%).  
- Total sales show a **consistent upward trend** from 2016 to 2018, indicating strong business growth.  
- Sales show **seasonal peaks** around June and September, with **dips in early spring (Feb–Apr)**.

## Recommendations
Early spring (Feb–Apr) may benefit from targeted promotions to boost weaker performance. Additionally, Q4 sales remain relatively flat; exploring customer behavior or marketing strategies during this period could help identify opportunities for improvement.

## Files in this Repository
- `01_exploratory_analysis.sql`  
- `02_advanced_analysis.sql`  
- `insights_summary.md`

## How to Run
1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database?resource=download).  
2. Import the SQL files (`01_exploratory_analysis.sql` and `02_advanced_analysis.sql`) into your preferred SQL environment (e.g., SQL Server, PostgreSQL, or MySQL).  
3. Execute the scripts in order.  
4. Review key insights in `insights_summary.md`.

## Future Improvements
- Add visualizations (e.g., Tableau or Power BI) to present trends and seasonality.  
- Incorporate additional years of data to confirm long-term trends.  
- Create KPIs or dashboards for store-level performance tracking.  
- Automate the analysis with stored procedures or scripts.

## Tools & Skills
SQL (joins, CTEs, window functions), data cleaning, exploratory data analysis, trend analysis, business insight generation.
