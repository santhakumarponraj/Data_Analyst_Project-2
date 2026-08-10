-- ============================================================
-- DATA CLEANING 
-- ============================================================

PRAGMA foreign_keys = ON;

-- Before cleanup

SELECT
    COUNT(*) AS invalid_incidents_before
FROM safety_incidents
WHERE driver_id IS NULL
   OR truck_id IS NULL;

--Incidents without a driver or truck are not valid 
--Only one row has a null driver_id in safety_incidents
--Truck_id is also null in only one row in safety_incidents.

DELETE
FROM safety_incidents
WHERE driver_id IS NULL
   OR truck_id IS NULL;

--Check if it deleted the two rows invalid_incidents should be 0

SELECT
    COUNT(*) AS invalid_incidents
FROM safety_incidents
WHERE driver_id IS NULL
   OR truck_id IS NULL;


--Data Standardization: Converting true/false -> 1,0

UPDATE safety_incidents
SET at_fault_flag =
    CASE
        WHEN at_fault_flag IN ('TRUE', 'True', 'true', 1) THEN 1
        WHEN at_fault_flag IN ('FALSE', 'False', 'false', 0) THEN 0
        ELSE NULL
    END,
    injury_flag =
    CASE
        WHEN injury_flag IN ('TRUE', 'True', 'true', 1) THEN 1
        WHEN injury_flag IN ('FALSE', 'False', 'false', 0) THEN 0
        ELSE NULL
    END,
    preventable_flag =
    CASE
        WHEN preventable_flag IN ('TRUE', 'True', 'true', 1) THEN 1
        WHEN preventable_flag IN ('FALSE', 'False', 'false', 0) THEN 0
        ELSE NULL
    END;

--Check

SELECT
    on_time_flag,
    COUNT(*) AS row_count
FROM delivery_events
GROUP BY on_time_flag
UNION ALL
SELECT
    at_fault_flag,
    COUNT(*) AS row_count
FROM safety_incidents
GROUP BY at_fault_flag
UNION ALL
SELECT
    injury_flag,
    COUNT(*) AS row_count
FROM safety_incidents
GROUP BY injury_flag
UNION ALL
SELECT
    preventable_flag,
    COUNT(*) AS row_count
FROM safety_incidents
GROUP BY preventable_flag;

