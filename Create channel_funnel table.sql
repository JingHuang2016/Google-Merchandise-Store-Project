

GO
create or alter view dbo.Channel_funnel_N as
WITH base AS (
    SELECT
        DATEFROMPARTS(YEAR(e.event_date), MONTH(e.event_date), 1) AS month_start,
        e.user_pseudo_id,
        e.session_id,
        e.new_event_name,
        c.marketing_channel,
        (case when new_event_name='First Visit' then 1
             when new_event_name='Page View' then 2
             when new_event_name='Product View' then 3
             when new_event_name='Add to Cart' then 4
             when new_event_name='Checkout' then 5
             when new_event_name='Purchase' then 6
             else null end) as step_order
    FROM dbo.bquxjob_Eventlevel e
    JOIN dbo.Campaign_adjusted c
      ON e.user_pseudo_id = c.user_pseudo_id
     AND e.session_id = c.ga_session_id
),
prep as (SELECT
    month_start,
    marketing_channel,
    new_event_name as funnel_stage,
    step_order,
    COUNT(DISTINCT session_id) AS session_count
FROM base
GROUP BY
    month_start,
    marketing_channel,
    new_event_name,
    step_order)
select *, 
    CAST(session_count * 1.0 /
    LAG(session_count) OVER (
      PARTITION BY month_start,marketing_channel
      ORDER BY step_order) AS DECIMAL(10,4)) as CVR
from prep;


