
GO
create or alter view dbo.item_funnel_priceband as
WITH priced AS (
  SELECT *,
    CASE
      WHEN price < 10 THEN '< $10'
      WHEN price BETWEEN 10 AND 25 THEN '$10–25'
      WHEN price BETWEEN 25 AND 50 THEN '$25–50'
      ELSE '$50+'
    END AS price_band
  FROM [GA4 Ecommerce Store].dbo.bquxjob_Itemlevel
), funnel AS (
  SELECT
    price_band,
    event_name,
    COUNT(DISTINCT ga_session_id) AS sessions
  FROM priced
  WHERE event_name IN ('view_item','add_to_cart','begin_checkout','purchase')
  GROUP BY price_band, event_name
)
SELECT
  price_band,
  event_name,
  sessions,
  CAST(
    sessions * 1.0 /
    LAG(sessions) OVER (
      PARTITION BY price_band
      ORDER BY
        CASE event_name
          WHEN 'view_item' THEN 1
          WHEN 'add_to_cart' THEN 2
          WHEN 'begin_checkout' THEN 3
          WHEN 'purchase' THEN 4
        END
    ) AS DECIMAL(10,4)
  ) AS step_conversion_rate
FROM funnel;

