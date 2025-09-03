# Analyze ecommerce website with SQL

### Query 01: calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
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

### Query 02: Bounce rate per traffic source in July 2017 

```sql
SELECT 
      trafficSource.source,
      COUNT(totals.visits) AS total_visit,
      COUNT(totals.bounces) AS total_no_of_bounce,
      ROUND((COUNT(totals.bounces))*100.0/COUNT(totals.visits),3) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY trafficSource.source
ORDER BY total_visit DESC;
```

### Query 3: Revenue by traffic source by week, by month in June 2017

```sql
WITH raw_data AS  
  (SELECT  
        date,
        trafficSource.source,
        productRevenue 
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
  UNNEST (hits) AS hits,
  UNNEST (product) AS product
  WHERE productRevenue IS NOT NULL)

, week_table AS 
  (SELECT 
        'Week' AS time_type,
        FORMAT_DATE('%Y%W', PARSE_DATE('%Y%m%d', date)) AS time,
        source,
        productRevenue
  FROM raw_data) 

, month_table AS
  (SELECT
        'Month' AS time_type,
        FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS time,
        source,
        productRevenue
  FROM raw_data)

SELECT 
      time_type,
      time, 
      source,
      ROUND(SUM(productRevenue)/1000000.0,4) AS revenue 
FROM week_table 
GROUP BY time_type, time, source 
UNION ALL
SELECT 
      time_type,
      time,
      source,
      ROUND(SUM(productRevenue)/1000000.0,4) AS revenue
FROM month_table
GROUP BY time_type, time, source;

```

### Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017

```sql
WITH raw_data AS   
  (SELECT 
        FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
        fullVisitorID, 
        productRevenue, 
        totals.pageviews,
        totals.transactions
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST (hits) AS hits,
  UNNEST (hits.product) AS product 
  WHERE _table_suffix BETWEEN '0601' AND '0731')

, purchaser AS 
  (SELECT 
        month,
        SUM(pageviews)/COUNT(distinct fullVisitorID) AS avg_pageviews_purchase
  FROM raw_data
  WHERE transactions >= 1 AND productRevenue IS NOT NULL
  GROUP BY month)

, non_purchaser AS 
  (SELECT 
          month,
          SUM(pageviews)/COUNT(distinct fullVisitorID) AS avg_pageviews_non_purchase
   FROM raw_data
   WHERE productRevenue IS NULL AND transactions IS NULL
   GROUP BY month)

SELECT
      purchaser.month,
      avg_pageviews_purchase,
      avg_pageviews_non_purchase
FROM purchaser
LEFT JOIN non_purchaser 
USING(month)
ORDER BY purchaser.month;
```

### Query 05: Average number of transactions per user that made a purchase in July 2017

```sql
WITH raw_data AS 
      (SELECT 
            FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
            fullVisitorID, 
            productRevenue, 
            totals.transactions
      FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
      UNNEST (hits) AS hits,
      UNNEST (hits.product) AS product)

SELECT 
      month, 
      SUM(transactions)/COUNT(DISTINCT fullVisitorID) AS avg_total_transactions_per_user
FROM raw_data
WHERE productRevenue IS NOT NULL AND transactions >= 1
GROUP BY 1;
```

### Query 06: Average amount of money spent per session. Only include purchaser data in July 2017

```sql
SELECT 
      FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
      ROUND(SUM(productRevenue)/(COUNT(fullVisitorID)*1000000.0), 2) AS avg_revenue_by_user_per_visit
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST (hits) AS hits,
UNNEST (hits.product) AS product
WHERE totals.transactions IS NOT NULL AND productRevenue IS NOT NULL 
GROUP BY FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date));
```

### Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017.
```sql
WITH raw_data AS     
      (SELECT 
            FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
            fullVisitorID, 
            productRevenue, 
            totals.transactions,
            v2productName,
            productQuantity
      FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
      UNNEST (hits) AS hits,
      UNNEST (hits.product) AS product
      WHERE productRevenue IS NOT NULL 
      AND totals.transactions IS NOT NULL)

SELECT 
      v2productName AS other_purchased_products,
      SUM(productQuantity) AS quantity
FROM raw_data
WHERE fullVisitorID IN (SELECT DISTINCT fullVisitorID
                  FROM raw_data
                  WHERE v2productName = "YouTube Men's Vintage Henley")
AND v2productName <> "YouTube Men's Vintage Henley"
GROUP BY v2productName
ORDER BY quantity DESC;
```

### Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. 
```sql
with
product_view as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '2'
  GROUP BY 1
),

add_to_cart as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '3'
  GROUP BY 1
),

purchase as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '6'
  and product.productRevenue is not null 
  group by 1
)

select
    pv.*,
    num_addtocart,
    num_purchase,
    round(num_addtocart*100/num_product_view,2) as add_to_cart_rate,
    round(num_purchase*100/num_product_view,2) as purchase_rate
from product_view pv
left join add_to_cart a on pv.month = a.month
left join purchase p on pv.month = p.month
order by pv.month;
```
