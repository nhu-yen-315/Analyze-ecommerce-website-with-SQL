-- Project: Analyze web performance, user engagement and sales performance for an e-commerce website with SQL

-- Query 1.1
SELECT 
      FORMAT_DATE('%Y-%m', PARSE_DATE('%Y%m%d',date)) AS month,
      SUM(totals.visits) AS total_visit,
      SUM(totals.pageviews) AS total_pageview,
      SUM(totals.transactions) AS total_transaction
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _table_suffix BETWEEN '0101' AND '0731'
GROUP BY 1
ORDER BY month;

-- Query 2.1: Revenue by traffic source
SELECT 
      trafficSource.source,
      SUM(p.productRevenue/1000000) AS total_revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
      unnest(hits) hits,
      unnest(product) AS p
WHERE _table_suffix BETWEEN '0101' AND '0731'
GROUP BY 1
ORDER BY 2 DESC;

-- Query 2.2: Revenue per session by traffic source
SELECT 
      trafficSource.source,
      SUM(p.productRevenue/1000000)/SUM(totals.visits) AS total_revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
      unnest(hits) hits,
      unnest(product) AS p
WHERE _table_suffix BETWEEN '0101' AND '0731'
GROUP BY 1
ORDER BY 2 DESC;

-- Query 3.1: Bounce rate per traffic source
SELECT 
      trafficSource.source,
      COUNT(totals.visits) AS total_visit,
      COUNT(totals.bounces) AS total_no_of_bounce,
      ROUND((COUNT(totals.bounces))*100.0/COUNT(totals.visits),3) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _table_suffix BETWEEN '0101' AND '0731'
GROUP BY trafficSource.source
ORDER BY total_visit DESC;

-- Query 3.2: Average number of page views by purchaser type (purchasers vs non-purchasers)
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

-- Query 3.3: Average amount of time per session by purchaser type (purchasers vs non-purchasers)
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

-- Query 3.4: Average number of transactions per user that made a purchase
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

-- Query 3.5: Calculate conversion rates from "view product" to "add to cart" and "purchase"
WITH product_data AS(
SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
    COUNT(CASE WHEN eCommerceAction.action_type = '2' THEN product.v2ProductName END) AS num_product_view,
    COUNT(CASE WHEN eCommerceAction.action_type = '3' THEN product.v2ProductName END) AS num_add_to_cart,
    COUNT(CASE WHEN eCommerceAction.action_type = '6' and product.productRevenue is not null THEN product.v2ProductName END) AS num_purchase
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) AS hits
    ,UNNEST (hits.product) AS product
WHERE _table_suffix BETWEEN '0101' AND '0731'
AND eCommerceAction.action_type IN ('2','3','6')
GROUP BY month
ORDER BY month
)

SELECT
    *,
    ROUND(num_add_to_cart/num_product_view * 100, 2) AS add_to_cart_rate,
    ROUND(num_purchase/num_product_view * 100, 2) AS purchase_rate
FROM product_data;

-- Query 4.1: The best-selling product by month
WITH sales AS
  (SELECT
        FORMAT_DATE('%Y-%m', PARSE_DATE('%Y%m%d', date)) AS month,
        p.v2ProductName AS product,
        SUM(p.productQuantity) AS quantity
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
    UNNEST(hits) AS hits,
    UNNEST(hits.product) AS p
  WHERE _table_suffix BETWEEN '0101' AND '0731' 
  AND p.productRevenue IS NOT NULL AND totals.transactions >= 1
  GROUP BY 1,2)

SELECT month, product, quantity
FROM (
  SELECT *,
         RANK() OVER (PARTITION BY month ORDER BY quantity DESC) AS rnk
  FROM sales
) AS ranked
WHERE rnk = 1
ORDER BY ranked.month;

-- Query 4.2: Which products are often purchased with Maze Pen and Google Sunglasses?
SELECT * FROM    
    (SELECT
        'Maze Pen' AS top_product,
        p.v2ProductName AS other_purchased_product,
        SUM(p.productQuantity) AS quantity
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
        UNNEST(hits) AS hits,
        UNNEST(hits.product) AS p
    WHERE _table_suffix BETWEEN '0101' AND '0731' 
    AND fullVisitorID IN (
        SELECT fullVisitorID
        FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
        UNNEST(hits) AS hits,
        UNNEST(hits.product) AS p
        WHERE _table_suffix BETWEEN '0101' AND '0731'
        AND p.v2ProductName = 'Maze Pen'
        AND p.productRevenue IS NOT NULL AND totals.transactions >= 1
    )
    AND p.v2ProductName != 'Maze Pen'
    AND p.productRevenue IS NOT NULL 
    AND totals.transactions >= 1
    GROUP BY p.v2ProductName
    ORDER BY quantity DESC
    LIMIT 3)

UNION ALL

SELECT * FROM    
    (SELECT
        'Google Sunglasses' AS top_product,
        p.v2ProductName AS other_purchased_product,
        SUM(p.productQuantity) AS quantity
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
        UNNEST(hits) AS hits,
        UNNEST(hits.product) AS p
    WHERE _table_suffix BETWEEN '0101' AND '0731' 
    AND fullVisitorID IN (
        SELECT fullVisitorID
        FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
        UNNEST(hits) AS hits,
        UNNEST(hits.product) AS p
        WHERE _table_suffix BETWEEN '0101' AND '0731'
        AND p.v2ProductName = 'Google Sunglasses'
        AND p.productRevenue IS NOT NULL AND totals.transactions >= 1
    )
    AND p.v2ProductName != 'Google Sunglasses'
    AND p.productRevenue IS NOT NULL 
    AND totals.transactions >= 1
    GROUP BY p.v2ProductName
    ORDER BY quantity DESC
    LIMIT 3);