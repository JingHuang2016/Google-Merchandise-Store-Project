
SELECT
  DATE(PARSE_DATE('%Y%m%d', e.event_date)) AS event_date,
  TIMESTAMP_MICROS(e.event_timestamp)      AS event_ts_utc,
  e.event_name,
  e.user_pseudo_id,
  -- session keys
  (SELECT ep.value.int_value FROM UNNEST(e.event_params) ep WHERE ep.key='ga_session_id' LIMIT 1)     AS session_id,
  (SELECT ep.value.int_value FROM UNNEST(e.event_params) ep WHERE ep.key='ga_session_number' LIMIT 1) AS session_number,
  -- campaign-lite 
  e.traffic_source.source  AS source,
  e.traffic_source.medium  AS medium,
  e.traffic_source.name    AS campaign,
  -- geo/device
  e.geo.country            AS country,
  e.geo.city               AS city,
  e.device.category        AS device_category,
  -- ecommerce context 
  e.ecommerce.purchase_revenue_in_usd AS purchase_revenue_in_usd,
  e.ecommerce.total_item_quantity     AS total_item_quantity,
  e.ecommerce.unique_items            AS unique_items,
  COALESCE(e.ecommerce.purchase_revenue_in_usd, e.event_value_in_usd) AS revenue,
  -- handy params
  (SELECT ep.value.string_value FROM UNNEST(e.event_params) ep WHERE ep.key='transaction_id' LIMIT 1) AS transaction_id,
  (SELECT ep.value.string_value FROM UNNEST(e.event_params) ep WHERE ep.key='page_location'   LIMIT 1) AS page_location
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
WHERE _TABLE_SUFFIX BETWEEN '20201001' AND '20210131';



SELECT
  DATE(PARSE_DATE('%Y%m%d', e.event_date)) AS event_date,
  e.event_name,
  e.user_pseudo_id,
  e.traffic_source.source  AS source,
  e.traffic_source.medium  AS medium,
  e.traffic_source.name    AS campaign,
  e.geo.country            AS country,
  e.geo.city               AS city,
  e.device.category        AS device_category,
  -- order id 
  (SELECT ep.value.string_value FROM UNNEST(e.event_params) ep WHERE ep.key='transaction_id' LIMIT 1) AS transaction_id,
  -- items 
  i.item_id,
  i.item_name,
  i.item_category,
  i.price,
  i.quantity,
  i.item_revenue,
  i.coupon,
  i.promotion_name
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
LEFT JOIN UNNEST(e.items) AS i
WHERE _TABLE_SUFFIX BETWEEN '20201001' AND '20210131';