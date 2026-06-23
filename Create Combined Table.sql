use [GA4 Ecommerce Store];

GO
create or alter view dbo.Combined_Table as
WITH sessions AS (
  SELECT
    e.user_pseudo_id,
    e.session_id,
    MIN(e.event_date) AS session_date,
    MAX(CASE WHEN e.event_name = 'purchase' THEN 1 ELSE 0 END) AS purchase_flag
  FROM dbo.bquxjob_Eventlevel$ AS e
  GROUP BY
    e.user_pseudo_id,
    e.session_id
),

/*** 2) Aggregate ITEMS to session (PURCHASE-ONLY!) ***/
item_session_agg AS (
  SELECT
    i.user_pseudo_id,
    i.ga_session_id AS session_id,              -- item table key
    COUNT(*) AS item_rows,                      -- # item rows in purchase events
    SUM(CASE WHEN i.quantity IS NULL THEN 0 ELSE i.quantity END) AS total_quantity,
    SUM(CASE WHEN i.item_revenue IS NULL THEN 0 ELSE i.item_revenue END) AS item_revenue
  FROM dbo.bquxjob_Itemlevel AS i
  WHERE
      -- SAFEST purchase-only filter:
      i.transaction_id IS NOT NULL
      -- Optional extra safety (uncomment if needed):
      -- AND i.item_revenue IS NOT NULL
      -- Optional outlier removal for non-transaction rows is not needed here,
      -- because we already require transaction_id IS NOT NULL.
  GROUP BY
    i.user_pseudo_id,
    i.ga_session_id
),

/*** 3) Deduplicate CAMPAIGN to session (1 row per session) ***/
campaign_session AS (
  SELECT
    c.user_pseudo_id,
    c.ga_session_id AS session_id,
    -- Pick a single channel per session (simple, stable)
    COALESCE(
      MAX(CASE WHEN c.marketing_channel IS NOT NULL AND LTRIM(RTRIM(c.marketing_channel)) <> ''
               THEN c.marketing_channel END),
      'Unknown'
    ) AS marketing_channel
  FROM dbo.Campaign_adjusted AS c
  GROUP BY
    c.user_pseudo_id,
    c.ga_session_id
)

/*** 4) Final combined session fact ***/
SELECT
  s.user_pseudo_id,
  s.session_id,
  s.session_date,

  cs.marketing_channel,

  s.purchase_flag,

  -- Item metrics (purchase-only). If no purchase, these will be NULL -> coalesce to 0 if you prefer.
  COALESCE(isa.item_rows, 0) AS item_count,
  COALESCE(isa.total_quantity, 0) AS total_quantity,
  COALESCE(isa.item_revenue, 0) AS item_revenue

FROM sessions AS s
LEFT JOIN campaign_session AS cs
  ON s.user_pseudo_id = cs.user_pseudo_id
 AND s.session_id     = cs.session_id
LEFT JOIN item_session_agg AS isa
  ON s.user_pseudo_id = isa.user_pseudo_id
 AND s.session_id     = isa.session_id;

