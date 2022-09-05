-- TOP TRAFFIC ANALYSIS
-- finding top traffic before April 12, 2012. The result is breakdown by UTM source, campaign, and referring domain
SELECT
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY 
	utm_source,
    utm_campaign,
    http_referer
ORDER BY 
	sessions DESC;
# from this result, we need to focus on gsearch nonbrand to optimize or learn more

-- TRAFFIC CONVERSATION RATE
-- drill deeper into gsearch nonbrand campaign traffic to explore potential optimization opportunities
-- we need to understand if those sessions are driving sales. So calculate the conversion rate from session to order
-- if CVR is at least in 4% then we can increase bids to drive more volume, else we need to reduce bids.
SELECT 
	COUNT(DISTINCT a.website_session_id) AS sessions,
    COUNT(DISTINCT b.order_id) AS orders,
    COUNT(DISTINCT b.order_id)/COUNT(DISTINCT a.website_session_id) AS session_to_order_conv_rt
FROM website_sessions a
	LEFT JOIN orders b
		ON a.website_session_id = b.website_session_id
WHERE 
	a.created_at < '2012-04-14' AND 
	a.utm_source = 'gsearch' AND
	a.utm_campaign = 'nonbrand';
# based on this analysis, we'll need to dial down our search bids a bit.


-- TRAFFIC SOURCE TRENDING
-- Monitor the impact of bid reductions
-- Analyze perfomance trending by device type in order to refine bidding strategy
-- Marketing director bid down gsearch nonbrand on 2012-04-15, we are asked to pull the trended session volume by week
SELECT 
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions 
WHERE 
	utm_source = 'gsearch' AND
	utm_campaign = 'nonbrand' AND
	created_at < '2012-05-12'
GROUP BY
	YEAR(created_at),
	WEEK(created_at);
# based on the analysis, gsearch nonbrand is sensitive to bid changes and reduce volume


-- TRAFFIC SOURCE BID OPTIMIZATION
-- Check the conversion rates from session to order by device type.
-- If desktop performance is better than mobile, they may be able to bid up for desktop
SELECT
	a.device_type,
	COUNT(DISTINCT a.website_session_id) AS sessions,
	COUNT(DISTINCT b.order_id) AS orders,
    COUNT(DISTINCT b.order_id)/COUNT(DISTINCT a.website_session_id) AS session_to_order_conv_rt
FROM website_sessions a
	LEFT JOIN orders b
		ON a.website_session_id = b.website_session_id
WHERE
	a.utm_source = 'gsearch' AND
	a.utm_campaign = 'nonbrand' AND
	a.created_at < '2012-05-11'
GROUP BY
	a.device_type;
# we can say that desktop device has greater conversion rate than mobile, so they need to bid up the desktop device
SELECT * FROM website_sessions;

-- TRAFFIC SOURCE SEGMENT TRENDING
SELECT
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions
FROM 
	website_sessions
WHERE
	utm_source = 'gsearch' AND
	utm_campaign = 'nonbrand' AND
	created_at BETWEEN '2012-04-15' AND '2012-06-09'
GROUP BY
	YEAR(created_at),
    WEEK(created_at);
# we can see that the bid changes the traffic from both device. Due to bid up of desktop device, so the traffic is looking strong than before
		








