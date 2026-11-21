-- 03_conversion_por_canal.sql
-- Purpose: add the conversion rate (buyers ÷ users × 100) per channel.
-- First version: the formulas are repeated inside SAFE_DIVIDE because
-- column aliases can't be reused in the same SELECT. See 04 for the CTE version.

SELECT
  traffic_source.medium AS canal,
  COUNT(DISTINCT user_pseudo_id) AS usuarios,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS compradores,
  ROUND(SAFE_DIVIDE(
    COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)),
    COUNT(DISTINCT user_pseudo_id)
  ) * 100, 2) AS conversion_pct
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY canal
ORDER BY usuarios DESC;
