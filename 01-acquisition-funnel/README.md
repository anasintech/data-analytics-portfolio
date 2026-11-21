# Conversion Rate by Acquisition Channel (GA4 E-commerce)

**Query:** [04_conversion_cte.sql](./sql/04_conversion_cte.sql)
**Tools:** Google BigQuery · SQL (CTEs, conditional aggregation, `SAFE_DIVIDE`)
**Dataset:** `bigquery-public-data.ga4_obfuscated_sample_ecommerce` (Google Merchandise Store, GA4 export)

---

## Business question

Which acquisition channels bring in the most users, and which ones turn those users into buyers?

## Approach

1. **Group users by channel.** I used `traffic_source.medium`, which in the GA4 export is the medium that first brought each user to the site (first-touch acquisition).
2. **Count unique users and unique buyers per channel.** To count buyers, I used conditional aggregation: `COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL))`.
3. **Calculate the conversion rate** as buyers ÷ users × 100. I used `SAFE_DIVIDE` so the query returns `NULL` instead of failing if a channel has zero users.
4. **Filter out noise.** I excluded `<Other>` and `(data deleted)`, which are placeholder values created by the dataset's obfuscation and don't represent real channels.

I wrapped the aggregation in a CTE (`por_canal`) so that the main query stays short and readable.

## Query

```sql
WITH por_canal AS (
  SELECT
    traffic_source.medium AS canal,
    COUNT(DISTINCT user_pseudo_id) AS usuarios,
    COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS compradores
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  GROUP BY canal
)
SELECT
  canal,
  usuarios,
  compradores,
  ROUND(SAFE_DIVIDE(compradores, usuarios) * 100, 2) AS conversion_pct
FROM por_canal
WHERE canal NOT IN ('<Other>', '(data deleted)')
ORDER BY usuarios DESC;
```

## Results

| Channel | Users | Buyers | Conversion rate |
|---|---:|---:|---:|
| organic | 112,358 | 1,323 | 1.18% |
| (none) — direct | 75,951 | 1,054 | 1.39% |
| referral | 55,495 | 1,026 | **1.85%** |
| cpc — paid search | 15,528 | 152 | 0.98% |

## Key findings

- **Referral is the best-converting channel (1.85%).** It ranks third by volume, but users who arrive from other websites are the most likely to buy.
- **Organic search brings the most traffic** (more than 112K users). Its conversion rate, though, is below that of direct and referral traffic.
- **Paid search (cpc) has the lowest conversion rate (0.98%).** It is the only channel here with a direct cost per click, and it converts at roughly half the rate of referral.

## Recommendation

Paid campaigns deserve a closer look. The next step would be to check keyword targeting and landing pages. At the same time, referral partnerships may be worth more investment, since that channel is already turning visitors into buyers more efficiently.

## Use of AI

I used Claude as a SQL tutor while building this analysis. I wrote each query myself and used AI to review syntax errors and check my approach. I validated every result independently: I recalculated the conversion rates by hand and caught a reversed division (`SAFE_DIVIDE(users, buyers)`) because it returned rates above 100%.

## Limitations

- The dataset is an **obfuscated sample** (Nov 2020 – Jan 2021), so some values are masked, and results may not match the real store exactly.
- `traffic_source.medium` reflects **first-touch** acquisition. A user who first arrived through organic search and later bought after clicking an ad is counted under organic.
- Conversion here is **user-level** (did the user ever purchase?). It doesn't measure revenue or the number of orders.
