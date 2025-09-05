# Analyze web performance and user behavior for an e-commerce website with SQL 
Author: Huỳnh Như Yến  
Date: 09-2025 <br>
Tools Used: SQL, BigQuery 

---

## 📑 Table of Contents  
1. [📌 Background & Overview](#-background--overview)  
2. [📂 Dataset Description](#-dataset-description)
3. [⚒ Queries and Insights](#-queries-and-insights)
4. [🔎 Recommendations](#-recommendations)

---

## 1. 📌 Background & Overview  

#### Objective:
#### 📖 What is this project about? What Business Question will it solve?

#### 👤 Who is this project for?

---

## 2. 📂 Dataset Description  

#### 📌 Data Source  
- Source: (Mention where the dataset is obtained from—Kaggle, company database, government sources, etc.)  
- Size: (Mention the number of rows & columns)  
- Format: (.csv, .sql, .xlsx, etc.)

#### 📂 Data description

---
## 3. ⚒ Queries and Insights

### Task 1: Web performance analysis

#### ⚒ Query 1.1: calculate total visit, pageview, transaction by month
```sql 
WITH raw_data AS   
  (SELECT 
        FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
        totals.visits, 
        totals.pageviews, 
        totals.transactions
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  WHERE _table_suffix between '0101' and '0331')

SELECT 
      month,
      COUNT(visits) AS visits,
      SUM(pageviews) AS pageviews,
      SUM(transactions) AS transactions
FROM raw_data
GROUP BY raw_data.month
ORDER BY month;
```
#### 👉🏻 Results:

#### 🔎 Insights: 

--- 

### Task 2: Revenue analysis

#### ⚒ Query 2.1: Revenue by traffic source

#### 👉🏻 Results:

#### 🔎 Insights:

#### ⚒ Query 2.2: Revenue per session (RPS) by traffic source

#### 👉🏻 Results:

#### 🔎 Insights:

---
### Task 3: User behavior analysis 

#### ⚒ Query 3.1: Bounce rate per traffic source

#### 👉🏻 Results:

#### 🔎 Insights:

#### ⚒ Query 3.2: Average number of pageviews by purchaser type (purchasers vs non-purchasers) 

#### 👉🏻 Results:

#### 🔎 Insights:

#### ⚒ Query 3.3: Average amount of time per session by purchaser type (purchasers vs non-purchasers)

#### 👉🏻 Results:

#### 🔎 Insights:

#### ⚒ Query 3.4: Average number of transactions per user that made a purchase

#### 👉🏻 Results:

#### 🔎 Insights:

#### ⚒ Query 3.5: Calculate conversion rates from "view product" to "add to cart" and "purchase"
#### 👉🏻 Results:

#### 🔎 Insights:

---
### ⚒ Task 4: Best-selling product analysis
#### 👉🏻 Results:

#### 🔎 Insights:

--- 
## 4.🔎 Recommendations
