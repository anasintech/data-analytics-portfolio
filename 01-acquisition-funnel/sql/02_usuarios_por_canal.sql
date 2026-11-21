-- 02_usuarios_por_canal.sql
-- Purpose: count unique users and unique buyers per acquisition channel.
-- Note: user_pseudo_id is used instead of user_id (user_id is NULL in this sample).

SELECT
  traffic_source.medium AS canal,
  COUNT(DISTINCT user_pseudo_id) AS usuarios,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS compradores
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY canal
ORDER BY usuarios DESC;
