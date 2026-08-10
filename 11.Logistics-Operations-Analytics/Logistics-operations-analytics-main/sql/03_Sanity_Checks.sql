-- ============================================================
-- Sanity checks (Run after schema creation, CSV load, and cleanup)
-- ============================================================

PRAGMA foreign_keys = ON;
PRAGMA foreign_keys;
PRAGMA integrity_check;

-- Row count checks

SELECT
    'customers' AS table_name,
    COUNT(*) AS row_count
FROM customers
UNION ALL
SELECT
    'routes',
    COUNT(*)
FROM routes
UNION ALL
SELECT
    'facilities',
    COUNT(*)
FROM facilities
UNION ALL
SELECT
    'drivers',
    COUNT(*)
FROM drivers
UNION ALL
SELECT
    'trucks',
    COUNT(*)
FROM trucks
UNION ALL
SELECT
    'trailers',
    COUNT(*)
FROM trailers
UNION ALL
SELECT
    'loads',
    COUNT(*)
FROM loads
UNION ALL
SELECT
    'trips',
    COUNT(*)
FROM trips
UNION ALL
SELECT
    'delivery_events',
    COUNT(*)
FROM delivery_events
UNION ALL
SELECT
    'fuel_purchases',
    COUNT(*)
FROM fuel_purchases
UNION ALL
SELECT
    'maintenance_records',
    COUNT(*)
FROM maintenance_records
UNION ALL
SELECT
    'safety_incidents',
    COUNT(*)
FROM safety_incidents
UNION ALL
SELECT
    'driver_monthly_metrics',
    COUNT(*)
FROM driver_monthly_metrics
UNION ALL
SELECT
    'truck_utilization_metrics',
    COUNT(*)
FROM truck_utilization_metrics;

-- Composite Primary key checks (should return zero rows)

SELECT
    driver_id,
    month
FROM driver_monthly_metrics
GROUP BY driver_id, month
HAVING COUNT(*) > 1;

SELECT
    truck_id,
    month
FROM truck_utilization_metrics
GROUP BY truck_id, month
HAVING COUNT(*) > 1;

-- Orphan checks (expected result = 0)

SELECT
    COUNT(*) AS orphan_trips_load
FROM trips t
LEFT JOIN loads l ON l.load_id = t.load_id
WHERE t.load_id IS NOT NULL
  AND l.load_id IS NULL
UNION ALL
SELECT
    COUNT(*) AS orphan_trips_driver
FROM trips t
LEFT JOIN drivers d ON d.driver_id = t.driver_id
WHERE t.driver_id IS NOT NULL
  AND d.driver_id IS NULL
UNION ALL
SELECT
    COUNT(*) AS orphan_delivery_trip
FROM delivery_events e
LEFT JOIN trips t ON t.trip_id = e.trip_id
WHERE e.trip_id IS NOT NULL
  AND t.trip_id IS NULL
UNION ALL
SELECT
    COUNT(*) AS orphan_fuel_trip
FROM fuel_purchases fp
LEFT JOIN trips t ON t.trip_id = fp.trip_id
WHERE fp.trip_id IS NOT NULL
  AND t.trip_id IS NULL
UNION ALL
SELECT
    COUNT(*) AS orphan_maintenance_truck
FROM maintenance_records m
LEFT JOIN trucks tr ON tr.truck_id = m.truck_id
WHERE m.truck_id IS NOT NULL
  AND tr.truck_id IS NULL;

-- Required-field checks

SELECT
    COUNT(*) AS missing_load_keys
FROM loads
WHERE customer_id IS NULL
   OR route_id IS NULL;

SELECT
    COUNT(*) AS missing_trip_load
FROM trips
WHERE load_id IS NULL;

SELECT
    COUNT(*) AS missing_delivery_keys
FROM delivery_events
WHERE trip_id IS NULL
   OR load_id IS NULL
   OR facility_id IS NULL;

-- Main join coverage checks

SELECT
    (SELECT COUNT(*) FROM trips) AS expected_trips,
    (SELECT COUNT(*)
     FROM trips t
     JOIN loads l ON l.load_id = t.load_id) AS joined_trips;

SELECT
    (SELECT COUNT(*) FROM fuel_purchases) AS expected_fuel,
    (SELECT COUNT(*)
     FROM fuel_purchases fp
     JOIN trips t ON t.trip_id = fp.trip_id) AS joined_fuel;

-- Numeric sanity checks

SELECT
    COUNT(*) AS negative_trip_miles
FROM trips
WHERE actual_distance_miles < 0;

SELECT
    COUNT(*) AS negative_fuel_values
FROM fuel_purchases
WHERE gallons < 0
   OR total_cost < 0;

-- Spot-check joined rows

SELECT
    t.trip_id,
    t.dispatch_date,
    l.load_id,
    l.revenue,
    d.driver_id,
    d.first_name,
    tr.truck_id,
    tr.make
FROM trips t
JOIN loads l ON l.load_id = t.load_id
LEFT JOIN drivers d ON d.driver_id = t.driver_id
LEFT JOIN trucks tr ON tr.truck_id = t.truck_id
LIMIT 15;
