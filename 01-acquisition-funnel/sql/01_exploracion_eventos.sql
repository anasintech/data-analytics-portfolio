-- 01_exploracion_eventos.sql
-- Purpose: explore the dataset — which events exist and how often they occur.
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce (Nov 2020 – Jan 2021)

SELECT
  event_name,
  COUNT(*) AS eventos
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY event_name
ORDER BY eventos DESC;
