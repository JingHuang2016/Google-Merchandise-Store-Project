
use [GA4 Ecommerce Store];


select * from dbo.customer_rfem_seg;
SELECT
  CONCAT('R', R_score, 'F', F_score, 'E', E_score, 'M', M_score) AS rfmSegment,
  COUNT(distinct user_pseudo_id) AS customers
FROM dbo.customer_rfem_seg
GROUP BY CONCAT('R', R_score, 'F', F_score, 'E', E_score, 'M', M_score)
ORDER BY rfmSegment;

***************************

GO

CREATE OR ALTER VIEW dbo.customerseg_name AS
SELECT
  *,
CASE
    WHEN has_purchased = 1
     AND R_score >= 4
     AND (
          F_score >= 3
       OR M_score >= 3
       OR E_score >= 3
     )
      THEN 'Best Customers'

    WHEN has_purchased = 1
     AND R_score >= 3
      THEN 'Active Buyers'

    WHEN has_purchased = 0
     AND E_score >= 3
      THEN 'Engaged Browsers'

    WHEN R_score = 5
     AND F_score = 1
     AND E_score >= 2
      THEN 'New Customers'

    WHEN F_score = 1
     AND has_purchased = 1
      THEN 'One-Time Buyers'

    WHEN R_score <= 2
     AND has_purchased = 1
      THEN 'At Risk Buyers'

    ELSE 'Other / Low Activity'
END AS segment_name
FROM dbo.customer_rfem_seg;

