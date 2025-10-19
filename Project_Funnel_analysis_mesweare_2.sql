
## FUNNEL SEGMENTATION ANALYSIS 

Select * from user_activity_log ;
Select * from user_profile ;

/*this querry return the count and percentage  of users in each stages up until successful purchase */

WITH funnel_base AS (
  SELECT
    user_id,
    MIN(CASE WHEN event_type = 'visit' THEN event_time END) AS visit,
    MIN(CASE WHEN event_type = 'view_product' THEN event_time END) AS view_product,
    MIN(CASE WHEN event_type = 'add_to_cart' THEN event_time END) AS add_to_cart,
    MIN(CASE WHEN event_type = 'checkout' THEN event_time END) AS checkout,
    MIN(CASE WHEN event_type = 'purchase' THEN event_time END) AS purchase
  FROM user_activity_log
  GROUP BY user_id
),
counts AS (
  SELECT
    COUNT(*) AS total_users,
    COUNT(visit) AS visited,
    COUNT(add_to_cart) AS added_to_cart,
    COUNT(checkout) AS started_checkout,
    COUNT(purchase) AS purchased
  FROM funnel_base
)

SELECT
  total_users,
  
  visited,
  ROUND(100.0 * visited / total_users, 2) AS visited_pct,
  
  added_to_cart,
  ROUND(100.0 * added_to_cart / total_users, 2) AS add_to_cart_pct,
  
  started_checkout,
  ROUND(100.0 * started_checkout / total_users, 2) AS checkout_pct,
  
  purchased,
  ROUND(100.0 * purchased / total_users, 2) AS purchase_pct
FROM counts;


/*We’ll quantify the relationship by computing conversion rate = (unique purchasers / total unique visitors */

/*segmented values( country, gender*/

## BY COUNTRY
SELECT 
    up.country,
    COUNT(DISTINCT up.user_id) AS total_users,
    COUNT(DISTINCT CASE
            WHEN ua.event_type ='purchase' THEN ua.user_id
        END) AS purchasers,
    ROUND(COUNT(DISTINCT CASE
                    WHEN ua.event_type IN ('purchase' ) THEN ua.user_id
                END) * 100.0 / COUNT(DISTINCT up.user_id),
            2) AS conversion_rate_percent
FROM
    user_profile AS up
        LEFT JOIN
    user_activity_log AS ua ON up.user_id = ua.user_id
GROUP BY up.country
ORDER BY conversion_rate_percent DESC;   

 /*Interpretation:
•	Users from France and Australia show slightly higher conversion rates, suggesting stronger purchase intent or better funnel experience there.
•	Differences are small (~1–2%), so they may not be statistically significant without deeper testing.
*/

##BY GENDER

SELECT 
    up.gender,
    COUNT(DISTINCT up.user_id) AS total_users,
    COUNT(DISTINCT CASE
            WHEN ua.event_type ='purchase' THEN ua.user_id
        END) AS purchasers,
    ROUND(COUNT(DISTINCT CASE
                    WHEN ua.event_type IN ('purchase' ) THEN ua.user_id
                END) * 100.0 / COUNT(DISTINCT up.user_id),
            2) AS conversion_rate_percent
FROM
    user_profile AS up
        LEFT JOIN
    user_activity_log  ua ON up.user_id = ua.user_id
GROUP BY up.gender 
ORDER BY conversion_rate_percent DESC ;

/*Interpretation:
•	Male users are marginally more likely to convert than female or “other” gender categories.
•	The difference is small but consistent with other patterns (males slightly over-index).
*/

##BY DEVICE 
 SELECT 
    ua.device,
    COUNT(DISTINCT up.user_id) AS total_users,
    COUNT(DISTINCT CASE
            WHEN ua.event_type ='purchase' THEN ua.user_id
        END) AS purchasers,
    ROUND(COUNT(DISTINCT CASE
                    WHEN ua.event_type IN ('purchase' ) THEN ua.user_id
                END) * 100.0 / COUNT(DISTINCT up.user_id),
            2) AS conversion_rate_percent
FROM
    user_profile AS up
        LEFT JOIN
    user_activity_log  ua ON up.user_id = ua.user_id
GROUP BY ua.device 
ORDER BY conversion_rate_percent DESC ;

/*•	Mobile users convert best — possibly due to better UX , relaxed browsing environments, or accessibilty.  */

## By Referral Source

Select ua.referral_source ,
		COUNT(DISTINCT ua.user_id) AS total_users ,
        ROUND(COUNT(DISTINCT CASE WHEN  ua.event_type IN ("purchase") THEN ua.user_id END) * 100 
        / COUNT(DISTINCT up.user_id),2) As conversion_rate_percent
FROM 
	user_profile AS up 
LEFT JOIN
	 user_activity_log ua ON up.user_id=ua.user_id
GROUP BY ua.referral_source
ORDER BY conversion_rate_percent DESC ;
        
/* Interpretation:
•	email-driven and organic referral users have the strongest conversion performance.
•	Paid ads and social visitors convert worse — possibly less qualified or earlier in the funnel.
*/

## By Preferred Category 

Select up.preferred_category ,
		COUNT(DISTINCT ua.user_id) AS total_users ,
        ROUND(COUNT(DISTINCT CASE WHEN  ua.event_type IN ("purchase") THEN ua.user_id END) * 100 
        / COUNT(DISTINCT up.user_id),2) As conversion_rate_percent
FROM 
	user_profile AS up 
LEFT JOIN
	 user_activity_log ua ON up.user_id=ua.user_id
GROUP BY up.preferred_category
ORDER BY conversion_rate_percent DESC ;

/*Interpretation:
•	Shoppers interested in shirts or accessories are more conversion-driven than those preferring shoes, which may indicate pricing sensitivity or browsing intent. 
*/


/*Takeaways 
•	All conversion rates hover around 23–25%, with no significant differences on the number results .
*/

/*contingency table */
SELECT
    up.country,
    SUM(CASE WHEN ua.event_type IN ( 'purchase') THEN 1 ELSE 0 END) AS purchasers,
    SUM(CASE WHEN ua.event_type NOT IN ('purchase') THEN 1 ELSE 0 END) AS non_purchasers
FROM user_profile up
LEFT JOIN user_activity_log ua
    ON up.user_id = ua.user_id
GROUP BY up.country;

