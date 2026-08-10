--VIEW showing driver level performance to be ingested by Power BI

DROP VIEW IF EXISTS view_driver_performance_summary;

CREATE VIEW view_driver_performance_summary AS
SELECT 
    d.driver_id,
    d.first_name || ' ' || d.last_name AS full_name,
    COALESCE(SUM(dmm.total_miles), 0) AS total_miles_driven,        -- Additive measures were coalesced to 0 to reflect no activity 
    COALESCE(SUM(dmm.total_revenue), 0) AS total_revenue,           
    COALESCE(SUM(dmm.trips_completed), 0) AS total_trips_completed, 
    AVG(dmm.on_time_delivery_rate) AS average_on_time_delivery_rate,-- Non additive measures were left alone since 0 would reflect poor performance
    AVG(dmm.average_mpg) AS average_mpg,
    AVG(dmm.average_idle_hours) AS average_idle_hours,
    d.years_experience,
CASE 																-- Flag that shows which drivers are inactive or active
    WHEN COALESCE(SUM(dmm.trips_completed), 0) > 0 THEN 1
    ELSE 0
END AS Driver_Activity_Flag

FROM drivers d 
LEFT JOIN driver_monthly_metrics dmm 
ON d.driver_id = dmm.driver_id
GROUP BY d.driver_id, d.first_name, d.last_name, d.years_experience;

-- Separate monthly view created for time-series analysis in power BI (one row per driver per month)

DROP VIEW IF EXISTS view_driver_monthly_performance;

CREATE VIEW view_driver_monthly_performance AS
SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name AS full_name,
    dmm.month,
    COALESCE(dmm.total_miles, 0) AS total_miles,
    COALESCE(dmm.total_revenue, 0) AS total_revenue,
    COALESCE(dmm.trips_completed, 0) AS trips_completed,
    dmm.on_time_delivery_rate,
    dmm.average_mpg,
    dmm.average_idle_hours,
    d.years_experience
FROM drivers d
JOIN driver_monthly_metrics dmm
ON d.driver_id = dmm.driver_id;