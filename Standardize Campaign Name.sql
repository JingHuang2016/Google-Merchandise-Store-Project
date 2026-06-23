
Create or alter view dbo.Campaign_adjusted as
select event_date, user_pseudo_id, session_start_ts,ga_session_id, source, medium, 
CASE
  WHEN source = '(direct)' OR medium IN ('(none)', 'none') THEN 'Direct'

  WHEN LOWER(medium) = 'organic' THEN 'Organic Search'

  WHEN LOWER(medium) IN ('cpc', 'ppc', 'paid_search') THEN 'Paid Search'

  WHEN LOWER(medium) = 'referral' THEN 'Referral'

  WHEN source IN ('(data deleted)', '<Other>')
       OR medium IN ('(data deleted)', '<Other>')
       OR campaign IN ('(data deleted)', '<Other>') THEN 'Unattributed'

  ELSE 'Other'
END AS marketing_channel
from dbo.Campaign;