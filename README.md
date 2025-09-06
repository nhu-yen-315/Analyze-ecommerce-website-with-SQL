# Analyze web performance and user engagement for an e-commerce website with SQL 
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
- **User engagement analysis**: explore the behavior of purchasers and non-purchasers; analyze the **customer journey** from "view product" to "purchase".
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

- Total visits and page views are two key metrics to measure the popularity of a website. Higher total visits and higher page views indicate that more people visit the website and the content is attractive to audience.
- Since this is an e-commerce website, making visitors buying is the ultimate goal. Thus, the number of transactions is also an important metric to the business.

#### ⚒ Query 1.1: calculate total visit, page view, transaction by month
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

- The number of **transactions** experiences an **upward trend** during the observed period. May has the highest number of transactions at 1160.
--- 

### Task 2: Revenue analysis

#### ⚒ Query 2.1: Revenue by traffic source
```sql
SELECT 
      trafficSource.source,
      SUM(p.productRevenue/1000000) AS total_revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
      unnest(hits) hits,
      unnest(product) AS p
WHERE _table_suffix BETWEEN '0101' AND '0731'
GROUP BY 1
ORDER BY 2 DESC;
```
#### 👉🏻 Results:

<p align='center'>
     <img width="387" height="159" alt="image" src="https://github.com/user-attachments/assets/b565df6b-57f2-4493-ba3a-1e6b6f454304" />
</p>

#### 🔎 Insights:

- **Direct source** brings the **highest revenue**, at over **$708.000**, to the business, while **Google and Google Mail** are the next two important traffic sources at around **$166.000 and $12.262** respectively.
- **DoubleClick For Advertisers (dfa)** is an old brand name for Google Marketing Platform. If a session's traffic source is labeled as dfa, the exact traffic source is not identified. Hence, the total revenue coming from dfa delivers no meaningful information.

#### ⚒ Query 2.2: Revenue per session by traffic source
**Revenue per session (RPS)** is a **key performance metric** in web analytics. It informs: "**How much revenue, on average, do you make from each session (visit) to your site?**"

```sql
SELECT 
      trafficSource.source,
      SUM(p.productRevenue/1000000)/SUM(totals.visits) AS total_revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
      unnest(hits) hits,
      unnest(product) AS p
WHERE _table_suffix BETWEEN '0101' AND '0731'
GROUP BY 1
ORDER BY 2 DESC;
```
#### 👉🏻 Results:
<p align='center'>
      <img width="388" height="164" alt="image" src="https://github.com/user-attachments/assets/348a75f4-bcc7-4014-b242-856366d96e93" />
</p>

#### 🔎 Insights:
- **AOL Mail, Dealspotr and Google Mail** have the **highest revenue generated per session**.
- Even though **AOL Mail** and **Dealspotr** do not have high total revenues, each visitor coming from these two sources **spends more money** than others.

---
### Task 3: User engagement analysis 
- User engagement is how users engage with the website. In e-commerce context, great user engagement indicates that users are interested in products and intend to buy something.
- Key metrics to measure user engagement in e-commerce:
  + **Bounce rate**: whether visitor leave or stay in the website after viewing the landing page.
  + **Session duration**: how much time a visitor spends on the website.
  + **Pages per session**: how many pages a visitor views. 
  + **Conversion rates**: the percentage of visitors completing a desired action out of total visitors.

#### ⚒ Query 3.1: Bounce rate per traffic source
- **Bounce rate** is a metric to measure **user engagement**.
- It is the **percentage of site vistors who leave after viewing only one page** without taking any further action. 
- Higher bounce rate is undesireable, indicating that many visitors leave after viewing the landing page. There are several causes leading to high bounce rate:
  + Slow page speed
  + Visitors' concern is irrelevant to the content.
  + The visual and/or content of the landing page is not attractive.
  + The website is not compatible with the device.
  
```sql
SELECT 
      trafficSource.source,
      COUNT(totals.visits) AS total_visit,
      COUNT(totals.bounces) AS total_no_of_bounce,
      ROUND((COUNT(totals.bounces))*100.0/COUNT(totals.visits),3) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _table_suffix BETWEEN '0101' AND '0731'
GROUP BY trafficSource.source
ORDER BY total_visit DESC;
```

#### 👉🏻 Results:
<p align='center'>
     <img width="635" height="378" alt="image" src="https://github.com/user-attachments/assets/0a0cf62c-11a8-467f-816c-c5349291048b" />
</p>

#### 🔎 Insights:
- Considering traffic sources with above 1000 total visits, **Twitter (t.co), Youtube and Baidu** have the **highest bounce rates** at **70%, 68.2% and 68%** respectively. 
- Sources generating high revenues such as **Direct source, Google and Google Mail** have relatively **low bounce rates** in the range of 37% to 45%.

#### ⚒ Query 3.2: Average number of page views by purchaser type (purchasers vs non-purchasers) 
- Classifying visitors into purchaser and non-purchaser groups is useful to explore any differences in their behavior.
- Insights are helpful to come up with solutions to convert non-purchasers to purchasers. 

```sql
WITH raw_table AS
      (SELECT 
            FORMAT_DATE('%Y-%m', PARSE_DATE('%Y%m%d', date)) AS month,
            fullVisitorID,
            totals.transactions AS transaction_num,
            p.productRevenue AS revenue,
            totals.pageviews
      FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
            UNNEST(hits) hits,
            UNNEST(product) AS p
      WHERE _table_suffix BETWEEN '0101' AND '0731'
      )
, purchaser AS (
      SELECT 
            month,
            SUM(pageviews)/COUNT(DISTINCT fullVisitorID) AS avg_pageviews_purchaser
      FROM raw_table
      WHERE revenue IS NOT NULL AND transaction_num >= 1
      GROUP BY month
)
, non_purchaser AS (
      SELECT 
            month,
            SUM(pageviews)/COUNT(DISTINCT fullVisitorID) AS avg_pageviews_non_purchaser
      FROM raw_table
      WHERE revenue IS NULL AND transaction_num IS NULL
      GROUP BY month
)
SELECT 
      purchaser.month,
      purchaser.avg_pageviews_purchaser,
      non_purchaser.avg_pageviews_non_purchaser
FROM purchaser 
JOIN non_purchaser
ON purchaser.month = non_purchaser.month
ORDER BY purchaser.month;
```

#### 👉🏻 Results:
<p align='center'>
      <img width="659" height="216" alt="image" src="https://github.com/user-attachments/assets/56cf5e86-463a-419c-9f4f-12eac5572f14" />
</p>

#### 🔎 Insights:
- **Non-purchasers** consistently view **2.5 to 4 times more pages** than those who do.
- The gap is consistent across months, showing that it is a **structural behavior**.
- **More page views** are **not always desireable**. In this case, more page views reflect **confusion or dissatisfaction** since visitors **can't find the products** they want even when they browse many pages.
  
#### ⚒ Query 3.3: Average amount of time per session by purchaser type (purchasers vs non-purchasers)

```sql
WITH raw_table AS
      (SELECT 
            FORMAT_DATE('%Y-%m', PARSE_DATE('%Y%m%d', date)) AS month,
            fullVisitorID,
            totals.transactions AS transaction_num,
            p.productRevenue AS revenue,
            totals.timeOnSite AS duration
      FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
            UNNEST(hits) hits,
            UNNEST(product) AS p
      WHERE _table_suffix BETWEEN '0101' AND '0731'
      )
, purchaser AS (
      SELECT 
            month,
            SUM(duration)/COUNT(DISTINCT fullVisitorID) AS avg_duration_purchaser
      FROM raw_table
      WHERE revenue IS NOT NULL AND transaction_num >= 1
      GROUP BY month
)
, non_purchaser AS (
      SELECT 
            month,
            SUM(duration)/COUNT(DISTINCT fullVisitorID) AS avg_duration_non_purchaser
      FROM raw_table
      WHERE revenue IS NULL AND transaction_num IS NULL
      GROUP BY month
)
SELECT 
      purchaser.month,
      purchaser.avg_duration_purchaser,
      non_purchaser.avg_duration_non_purchaser
FROM purchaser 
JOIN non_purchaser
ON purchaser.month = non_purchaser.month
ORDER BY purchaser.month;
```
#### 👉🏻 Results:
<p align='center'>
      <img width="619" height="214" alt="image" src="https://github.com/user-attachments/assets/cf166c0a-5e46-4d1a-ab60-24b9894c52e7" />
</p>

#### 🔎 Insights:
- Consistent with the insight from query 3.2, **non-purchasers spend more time** within a session compared to purchasers.
- Purchasers are decisive. Once they found the desired products, they completed the purchase and finished the session.
- Non-purchasers spend more time to browse and find desired products.
  
#### ⚒ Query 3.4: Average number of transactions per user that made a purchase
```sql
SELECT 
      FORMAT_DATE('%Y-%m', PARSE_DATE('%Y%m%d', date)) AS month,
      SUM(totals.transactions)/COUNT(DISTINCT fullVisitorID) AS avg_transaction
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
      UNNEST(hits) hits,
      UNNEST(product) AS p
WHERE _table_suffix BETWEEN '0101' AND '0731'
AND totals.transactions >= 1 AND p.productRevenue IS NOT NULL
GROUP BY 1
ORDER BY month;
```
#### 👉🏻 Results:
<p align='center'>
      <img width="416" height="215" alt="image" src="https://github.com/user-attachments/assets/e3a59338-dc0e-4217-8a82-59d00c2c8fe1" />
</p>

#### 🔎 Insights:
- The average number of transactions per purchaser is **relatively stable** around **3.5 transactions** in most months.
- **March** is the **exception** when the average number reached the **peak at 8.6 transactions**. 
- **July** also shows **better-than-average** results, with **4.1 transactions** per purchaser..

#### ⚒ Query 3.5: Calculate conversion rates from "view product" to "add to cart" and "purchase"

#### 👉🏻 Results:

#### 🔎 Insights:

---
### ⚒ Task 4: Best-selling product analysis
#### 👉🏻 Results:

#### 🔎 Insights:

--- 
## 4.🔎 Recommendations

Improve product filtering/search to help users find relevant products faster.
