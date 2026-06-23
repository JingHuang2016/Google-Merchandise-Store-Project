
use [GA4 Ecommerce Store];

create view Customer_ltv as
with temp as
(select *
from dbo.bquxjob_Itemlevel
where event_name='purchase')

select user_pseudo_id, count(distinct transaction_id) as TotalOrders,
sum(item_revenue) as Totalrevenue,
min(event_date) as Firstorder,
max(event_date) as Lastorder,
datediff(day,min(event_date),max(event_date)) as Customerlifespan,
CAST(SUM(item_revenue) AS DECIMAL(10,2))
/ NULLIF(COUNT(DISTINCT transaction_id), 0) AS AOV
from temp
group by user_pseudo_id;

select totalrevenue,user_pseudo_id
from dbo.Customer_ltv
group by user_pseudo_id;
select * from dbo.Customer_LTV
order by Customerlifespan desc;

select * from dbo.cohort_matrix;




*****************Create cohort_table_1**************************

GO
create or alter view cohort_table_1 as
WITH firstInteraction AS (
  SELECT
    user_pseudo_id,
    MIN(event_date) AS first_interaction_date
  FROM dbo.bquxjob_Eventlevel$
  GROUP BY user_pseudo_id
),
firstTransaction AS (
  SELECT
    user_pseudo_id,
    MIN(event_date) AS first_transaction_date
  FROM dbo.purchaseorder
  GROUP BY user_pseudo_id
),
cohortprep AS (
  SELECT
    fi.user_pseudo_id,
    fi.first_interaction_date,
    ft.first_transaction_date,

    -- WEEK difference (true cohort timing)
    DATEDIFF(
      WEEK,
      fi.first_interaction_date,
      ft.first_transaction_date
    ) AS weeksSinceAcq,

    -- Cohort label (month of acquisition)
    DATEFROMPARTS(
      YEAR(fi.first_interaction_date),
      MONTH(fi.first_interaction_date),
      1
    ) AS cohort_month

  FROM firstInteraction fi
  LEFT JOIN firstTransaction ft
    ON fi.user_pseudo_id = ft.user_pseudo_id
)
SELECT
  cohort_month,
  weeksSinceAcq,
  COUNT(DISTINCT user_pseudo_id) AS activeCustomers
FROM cohortprep
GROUP BY
  cohort_month,
  weeksSinceAcq;

select * from dbo.cohort_table_1;


***************Cohort Matrix*****************
create view cohort_matrix as
WITH acquisition AS (
  SELECT
    user_pseudo_id,
    MIN(event_date) AS acquisition_date
  FROM dbo.bquxjob_Eventlevel$
  GROUP BY user_pseudo_id
),
purchases AS (
  SELECT
    user_pseudo_id,
    event_date AS purchase_date
  FROM dbo.purchaseorder
),
cohort_events AS (
  SELECT
    a.user_pseudo_id,
    DATEFROMPARTS(
      YEAR(a.acquisition_date),
      MONTH(a.acquisition_date),
      1
    ) AS cohort_month,

    DATEDIFF(
      WEEK,
      a.acquisition_date,
      p.purchase_date
    ) AS week_number
  FROM acquisition a
  JOIN purchases p
    ON a.user_pseudo_id = p.user_pseudo_id
)
SELECT
  cohort_month,
  week_number,
  COUNT(DISTINCT user_pseudo_id) AS active_users
FROM cohort_events
WHERE week_number >= 0
GROUP BY
  cohort_month,
  week_number;

select * from dbo.cohort_matrix;



