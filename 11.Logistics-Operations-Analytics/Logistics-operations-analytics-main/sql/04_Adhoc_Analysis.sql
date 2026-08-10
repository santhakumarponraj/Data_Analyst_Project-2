-- ============================================================
-- DRIVER PERFORMANCE ANALYSIS: AD-HOC BUSINESS QUESTIONS 
-- ============================================================

-- 1. Which drivers have the highest total revenue across the entire dataset?

SELECT 
	d.driver_id,
	d.first_name || ' ' || d.last_name AS Full_Name,
	COALESCE(SUM(dmm.total_revenue), 0) AS Total_Revenue
FROM
	drivers d
LEFT JOIN driver_monthly_metrics dmm ON
	d.driver_id = dmm.driver_id
GROUP BY
	d.driver_id,
	d.first_name,
	d.last_name
ORDER BY
	Total_Revenue DESC
LIMIT 10;

-- 2. Which drivers have completed the most total trips?

SELECT 
	d.driver_id,
	d.first_name || ' ' || d.last_name AS Full_Name,
	COALESCE(SUM(dmm.trips_completed), 0) AS Total_Trips_Completed
FROM
	drivers d
LEFT JOIN driver_monthly_metrics dmm ON
	d.driver_id = dmm.driver_id
GROUP BY
	d.driver_id,
	d.first_name,
	d.last_name
ORDER BY
	Total_Trips_Completed DESC
LIMIT 10;

-- 3. What is the average revenue per trip for each driver?

SELECT
	d.driver_id,
	d.first_name || ' ' || d.last_name AS Full_Name,
	1.0 * SUM(dmm.total_revenue) / SUM(dmm.trips_completed) AS Avg_Revenue_Per_Trip
	--Multiplying by 1.0 ensures decimals are not truncated
FROM
	drivers d
LEFT JOIN driver_monthly_metrics dmm
    ON
	d.driver_id = dmm.driver_id
GROUP BY
	d.driver_id,
	d.first_name,
	d.last_name
HAVING
	SUM(dmm.trips_completed) > 0
	-- removes drivers with undefined revenue per trip
ORDER BY
	Avg_Revenue_Per_Trip DESC;

-- 4. Which drivers have above-average revenue per trip
--    compared to the fleet average?

WITH fleet_avg AS (
SELECT
	1.0 * SUM(total_revenue) / SUM(trips_completed) AS Fleet_avg_revenue_per_trip
FROM
	driver_monthly_metrics
WHERE
	trips_completed > 0
)
SELECT
	d.driver_id,
	d.first_name || ' ' || d.last_name AS Full_Name,
	1.0 * SUM(dmm.total_revenue) / SUM(dmm.trips_completed) AS Avg_Revenue_Per_Trip,
	f.fleet_avg_revenue_per_trip AS Fleet_Avg_Revenue_Per_Trip,
	CASE
		WHEN (1.0 * SUM(dmm.total_revenue) / SUM(dmm.trips_completed))
             >= f.fleet_avg_revenue_per_trip
        THEN 'Above/Equal'
		ELSE 'Below'
	END AS Revenue_Per_Trip_Flag
FROM
	drivers d
JOIN driver_monthly_metrics dmm
    ON
	d.driver_id = dmm.driver_id
CROSS JOIN fleet_avg f
GROUP BY
	d.driver_id,
	d.first_name,
	d.last_name
HAVING
	SUM(dmm.trips_completed) > 0
ORDER BY
	Avg_Revenue_Per_Trip DESC;

-- 5. Which drivers have the highest on-time delivery rate on average?

SELECT 
	d.driver_id,
	d.first_name || ' ' || d.last_name AS Full_Name,
	AVG(dmm.on_time_delivery_rate) AS Avg_on_time_delivery_rate
FROM
	drivers d
LEFT JOIN driver_monthly_metrics dmm ON
	d.driver_id = dmm.driver_id
GROUP BY
	d.driver_id,
	d.first_name,
	d.last_name
ORDER BY
	avg_on_time_delivery_rate DESC
LIMIT 10;

-- 6. How many inactive drivers were in the dataset?

SELECT
	COUNT(DISTINCT d.driver_id) AS Total_drivers,
	COUNT(DISTINCT dmm.driver_id) AS Active_drivers,
	COUNT(DISTINCT d.driver_id) - COUNT(DISTINCT dmm.driver_id) AS Inactive_drivers
FROM
	drivers d
LEFT JOIN driver_monthly_metrics dmm
    ON
	d.driver_id = dmm.driver_id;

-- 7. What is the total revenue and total trips for the entire fleet?

SELECT
	COALESCE(SUM(dmm.total_revenue), 0) AS Total_Revenue,
	COALESCE(SUM(dmm.trips_completed), 0) AS Total_Trips_Completed
FROM
	driver_monthly_metrics dmm;

-- 8. Which drivers have below-average trips completed (low volume)
--    but above-average revenue per trip?

WITH driver_metrics AS (
SELECT
	d.driver_id,
	d.first_name || ' ' || d.last_name AS Full_name,
	SUM(dmm.trips_completed) AS Total_Trips_Completed,
	1.0 * SUM(dmm.total_revenue) / SUM(dmm.trips_completed) AS Revenue_per_trip
FROM
	drivers d
LEFT JOIN driver_monthly_metrics dmm
        ON
	d.driver_id = dmm.driver_id
GROUP BY
	d.driver_id,
	d.first_name,
	d.last_name
HAVING
	SUM(dmm.trips_completed) > 0
	-- prevent divide-by-zero / undefined revenue_per_trip
),
fleet_avgs AS (
SELECT
	AVG(Total_Trips_Completed) AS fleet_avg_trips_completed,
	AVG(revenue_per_trip) AS fleet_avg_revenue_per_trip
FROM
	driver_metrics
)
SELECT
	dm.driver_id,
	dm.full_name,
	dm.Total_Trips_Completed,
	fa.fleet_avg_trips_completed,
	dm.revenue_per_trip,
	fa.fleet_avg_revenue_per_trip
FROM
	driver_metrics dm
CROSS JOIN fleet_avgs fa
WHERE
	dm.Total_Trips_Completed < fa.fleet_avg_trips_completed
	AND dm.revenue_per_trip > fa.fleet_avg_revenue_per_trip
ORDER BY
	dm.revenue_per_trip DESC,
	dm.Total_Trips_Completed ASC;

-- 9. How does average revenue per trip differ between drivers
--    with less than 5 years of experience and those with 5+ years?

SELECT
	d.driver_id,
	d.first_name || ' ' || d.last_name AS Full_Name,
	1.0 * SUM(dmm.total_revenue) / SUM(dmm.trips_completed) AS Avg_Revenue_Per_Trip,
	CASE
		WHEN d.years_experience >= 5 THEN '5+ Years of Experience'
		ELSE 'Less than 5 years of Experience'
	END AS driver_experience
FROM
	drivers d
LEFT JOIN driver_monthly_metrics dmm
    ON
	d.driver_id = dmm.driver_id
GROUP BY
	d.driver_id,
	d.first_name,
	d.last_name,
	d.years_experience
HAVING
	SUM(dmm.trips_completed) > 0
ORDER BY
	Avg_Revenue_Per_Trip DESC;
