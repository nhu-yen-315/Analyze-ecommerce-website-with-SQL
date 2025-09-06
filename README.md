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

#### 📖 What is this project about? 

The project analyses a dataset of an e-commerce website using SQL. The analysis is divided into 4 parts:

- **Web performance analysis**: track web performance with key metrics like **total visit**, **page views** and **number of transactions**.
- **Revenue analysis**: analyze revenue by **traffic source**.
- **User behavior analysis**: explore the behavior of purchasers and non-purchasers; analyze the **customer journey** from "view product" to "purchase".
- **Best-selling product analysis**: analyze the best-selling product by month and products frequently purchased together.

These analyses are useful to:

- Keep in track the monthly performance of website
- Identify important **traffic sources**
- Understand the purchase behavior to **optimize conversion rates**
- Make data-driven **cross-selling strategies**



#### 👤 Who is this project for?
- Data analyst
- Business analyst
- Digital marketing team
- E-commerce manager and stakeholder
---

## 2. 📂 Dataset Description  

#### 📌 Data Source  
- Source: The dataset is from Google Analytics 4 (GA4), exported to BigQuery. It contains user activities on an e-commerce website.
- Size: (Mention the number of rows & columns)

#### 📂 Data description

---
## 3. ⚒ Queries and Insights

### Task 1: Web performance analysis

#### ⚒ Query 1.1: calculate total visit, pageview, transaction by month
```sql 
SELECT 
      FORMAT_DATE('%Y-%m', PARSE_DATE('%Y%m%d',date)) AS month,
      SUM(totals.visits) AS total_visit,
      SUM(totals.pageviews) AS total_pageview,
      SUM(totals.transactions) AS total_transaction
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _table_suffix BETWEEN '0101' AND '0731'
GROUP BY 1
ORDER BY month;
```
#### 👉🏻 Results:
<p align="center">
<img width="578" height="216" alt="image" src="https://github.com/user-attachments/assets/d1c8b30a-4501-4581-8a7d-09cf24336db3" />
</p>

#### 🔎 Insights: 
<p align="center">
<img width="400" height="250" alt="image" src="https://github.com/user-attachments/assets/c2ed18ee-6315-40d1-b7cd-4d19237387ef" />
</p>

- **Total visits** and **total page views** are relatively **stable** across the first seven months in 2017.

<p align="center">
<img width="400" height="250" alt="image" src="https://github.com/user-attachments/assets/04418dc6-ae6d-4d63-b58b-ac3f371c9724" />
</p>

- The number of **transactions** experiences an **upward trend** across months. May has the highest number of transactions at 1160.
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
