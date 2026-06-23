

create or alter view dbo.customer_rfem_seg as
WITH user_metrics AS (
  SELECT
    user_pseudo_id,

    -- R: last purchase date (preferred), and last session date (fallback)
    MAX(CASE WHEN purchase_flag = 1 THEN session_date END) AS last_purchase_date,
    MAX(session_date) AS last_session_date,

    -- F: purchase frequency (count of purchase sessions)
    SUM(CASE WHEN purchase_flag = 1 THEN 1 ELSE 0 END) AS purchase_sessions,

    -- E: engagement (either total sessions or max session_number)
    COUNT(DISTINCT session_id) AS total_sessions,

    -- M: monetary
    SUM(COALESCE(item_revenue, 0)) AS total_revenue

  FROM dbo.Combined_Table
  GROUP BY user_pseudo_id
),
user_rfem AS (
  SELECT
    user_pseudo_id,
    last_purchase_date,
    last_session_date,
    purchase_sessions,
    total_sessions,
    total_revenue,

    -- Recency in days:
    -- If user never purchased, use last session as fallback
    CASE
      WHEN last_purchase_date IS NOT NULL
        THEN DATEDIFF(DAY, last_purchase_date, CAST(GETDATE() AS date))
      ELSE DATEDIFF(DAY, last_session_date, CAST(GETDATE() AS date))
    END AS recency_days,

    -- Optional label to make interpretation easier
    CASE
      WHEN last_purchase_date IS NULL THEN 0 ELSE 1
    END AS has_purchased
  FROM user_metrics
),
scored AS (
  SELECT
    *,
    -- Recency: smaller is better => ORDER BY recency_days ASC
    NTILE(5) OVER (ORDER BY recency_days ASC) AS R_score,

    -- Frequency: bigger is better
    NTILE(5) OVER (ORDER BY purchase_sessions DESC) AS F_score,

    -- Engagement: bigger is better (use total_sessions; you can switch to max_session_number)
    NTILE(5) OVER (ORDER BY total_sessions DESC) AS E_score,

    -- Monetary: bigger is better
    NTILE(5) OVER (ORDER BY total_revenue DESC) AS M_score
  FROM user_rfem
)

SELECT
  user_pseudo_id,
  has_purchased,
  last_purchase_date,
  last_session_date,
  recency_days,
  purchase_sessions,
  total_sessions,
  total_revenue,
  R_score, F_score, E_score, M_score,
  (R_score + F_score + E_score + M_score) AS RFEM_total_score
FROM scored;