

CREATE OR ALTER VIEW dbo.bquxjob_Eventlevel AS
SELECT
    e.*,
    CASE
        WHEN e.event_name IN ('session_start', 'first_visit')
            THEN 'First Visit'
        WHEN e.event_name IN ('page_view','view_promotion','view_search_results','scroll')
            THEN 'Page View'
        WHEN e.event_name IN ('click','view_item', 'select_item','user_engagement','select_promotion')
            THEN 'Product View'
        WHEN e.event_name = 'add_to_cart'
            THEN 'Add to Cart'
        WHEN e.event_name IN ('begin_checkout', 'add_shipping_info', 'add_payment_info')
            THEN 'Checkout'
        WHEN e.event_name = 'purchase'
            THEN 'Purchase'
        ELSE 'Other'
    END AS new_event_name
FROM dbo.bquxjob_Eventlevel$ e;

