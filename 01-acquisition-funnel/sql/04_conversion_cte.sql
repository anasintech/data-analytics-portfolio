-- 04_conversion_cte.sql
-- Purpose: conversion rate by acquisition channel, rewritten with a CTE.
-- Excludes '<Other>' and '(data deleted)': placeholder values created by the
-- dataset's obfuscation, not real channels.

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
