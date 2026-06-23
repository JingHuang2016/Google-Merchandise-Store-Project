
SELECT
  -- Date level (optional; you can remove it if you want campaign-level only)
  DATE(PARSE_DATE('%Y%m%d', e.event_date)) AS event_date,

  -- Original GA4 source fields
  e.traffic_source.source AS source,
  e.traffic_source.medium AS medium,
  e.traffic_source.name   AS campaign,

  -- ✅ Derived Campaign Category
  CASE
    WHEN LOWER(e.traffic_source.medium) = 'organic' THEN 'Organic Search'
    WHEN LOWER(e.traffic_source.medium) IN ('cpc', 'ppc', 'paid_search') THEN 'Paid Search'
    WHEN LOWER(e.traffic_source.medium) IN ('social', 'paid_social', 'social_network') THEN 'Social'
    WHEN LOWER(e.traffic_source.source) = '(direct)' OR LOWER(e.traffic_source.medium) = '(none)' THEN 'Direct'
    WHEN LOWER(e.traffic_source.medium) = 'referral' THEN 'Referral'
    WHEN e.traffic_source.source IS NULL OR e.traffic_source.source = '(data deleted)' THEN 'Unattributed'
    ELSE 'Other'
  END AS campaign_category,

  -- ✅ Metrics
  COUNTIF(e.event_name = 'session_start') AS sessions,
  COUNTIF(e.event_name = 'purchase') AS transactions,
  SUM(CASE 
        WHEN e.event_name = 'purchase' 
        THEN COALESCE(e.ecommerce.purchase_revenue_in_usd, e.event_value_in_usd)
        ELSE 0 
      END) AS revenue

FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
WHERE _TABLE_SUFFIX BETWEEN '20201001' AND '20210131'
GROUP BY
  event_date,
  source,
  medium,
  campaign,
  campaign_category
ORDER BY
  revenue DESC;