--====================================================
--SCHMEA CREATION 
--====================================================
PRAGMA foreign_keys = ON;

--Table drops for reruns (order matters)

DROP TABLE IF EXISTS truck_utilization_metrics;
DROP TABLE IF EXISTS driver_monthly_metrics;
DROP TABLE IF EXISTS safety_incidents;
DROP TABLE IF EXISTS maintenance_records;
DROP TABLE IF EXISTS fuel_purchases;
DROP TABLE IF EXISTS delivery_events;
DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS loads;
DROP TABLE IF EXISTS trucks;
DROP TABLE IF EXISTS trailers;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS facilities;
DROP TABLE IF EXISTS customers;

--Dimension Tables

CREATE TABLE customers (
  customer_id              TEXT PRIMARY KEY,
  customer_name            TEXT,
  customer_type            TEXT,
  credit_terms_days        INTEGER,
  account_status           TEXT,
  annual_revenue_potential REAL,
  contract_start_date      TEXT,  
  primary_freight_type     TEXT
);

CREATE TABLE facilities (
  facility_id      TEXT PRIMARY KEY,
  city             TEXT,
  dock_doors       INTEGER,
  facility_name    TEXT,
  facility_type    TEXT,
  latitude         REAL,
  longitude        REAL,
  operating_hours  TEXT,
  state            TEXT
);

CREATE TABLE routes (
  route_id               TEXT PRIMARY KEY,
  base_rate_per_mile     REAL,
  destination_city       TEXT,
  destination_state      TEXT,
  fuel_surcharge_rate    REAL,
  origin_city            TEXT,
  origin_state           TEXT,
  typical_distance_miles REAL,
  typical_transit_days   INTEGER
);

CREATE TABLE drivers (
  driver_id         TEXT PRIMARY KEY,
  cdl_class         TEXT,
  date_of_birth     TEXT,
  employment_status TEXT,
  first_name        TEXT,
  hire_date         TEXT,
  home_terminal     TEXT,
  last_name         TEXT,
  license_number    TEXT,
  license_state     TEXT,
  termination_date  TEXT,
  years_experience  INTEGER
);

CREATE TABLE trailers (
  trailer_id       TEXT PRIMARY KEY,
  acquisition_date TEXT,
  current_location TEXT,
  length_feet      REAL,
  model_year       INTEGER,
  status           TEXT,
  trailer_number   TEXT, --Numbers identify trailer so it is treated as a text type
  trailer_type     TEXT,
  vin			   TEXT
);

CREATE TABLE trucks (
  truck_id              TEXT PRIMARY KEY,
  acquisition_date      TEXT,
  acquisition_mileage   INTEGER,
  fuel_type             TEXT,
  make                  TEXT,
  model_year            INTEGER,
  status                TEXT,
  tank_capacity_gallons REAL,
  unit_number           TEXT, --identification number so treated as text
  vin                   TEXT,
  home_terminal			TEXT
);


-- Fact Tables


CREATE TABLE loads (
  load_id             TEXT PRIMARY KEY,
  customer_id         TEXT NOT NULL, 
  route_id            TEXT NOT NULL, 
  booking_type        TEXT,
  fuel_surcharge      REAL,
  load_date           TEXT,
  load_status         TEXT,
  load_type           TEXT,
  pieces              INTEGER,
  revenue             REAL,
  weight_lbs          INTEGER,
  accessorial_charges REAL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (route_id)    REFERENCES routes(route_id)
);

CREATE TABLE trips (
  trip_id               TEXT PRIMARY KEY,
  load_id               TEXT NOT NULL,
  driver_id             TEXT, 
  truck_id              TEXT,
  trailer_id            TEXT,
  dispatch_date         TEXT,
  actual_distance_miles REAL,
  actual_duration_hours REAL,
  average_mpg           REAL,
  fuel_gallons_used     REAL,
  idle_time_hours		REAL,
  trip_status			TEXT,
  FOREIGN KEY (load_id)    REFERENCES loads(load_id),
  FOREIGN KEY (driver_id)  REFERENCES drivers(driver_id),
  FOREIGN KEY (truck_id)   REFERENCES trucks(truck_id),
  FOREIGN KEY (trailer_id) REFERENCES trailers(trailer_id)
);

CREATE TABLE delivery_events (
  event_id           TEXT PRIMARY KEY,
  trip_id            TEXT NOT NULL,
  load_id            TEXT NOT NULL,
  facility_id        TEXT NOT NULL,
  event_type         TEXT, 
  actual_datetime    TEXT,
  scheduled_datetime TEXT,
  on_time_flag       INTEGER,
  detention_minutes  INTEGER,
  location_city      TEXT,
  location_state     TEXT,
  FOREIGN KEY (trip_id)     REFERENCES trips(trip_id),
  FOREIGN KEY (load_id)     REFERENCES loads(load_id),
  FOREIGN KEY (facility_id) REFERENCES facilities(facility_id)
);

CREATE TABLE fuel_purchases (
  fuel_purchase_id TEXT PRIMARY KEY,
  trip_id          TEXT NOT NULL,
  truck_id         TEXT,
  driver_id        TEXT,
  fuel_card_number TEXT,
  purchase_date    TEXT,
  location_city    TEXT,
  location_state   TEXT,
  gallons          REAL,
  price_per_gallon REAL,
  total_cost       REAL,
  FOREIGN KEY (trip_id)   REFERENCES trips(trip_id),
  FOREIGN KEY (truck_id)  REFERENCES trucks(truck_id),
  FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

CREATE TABLE maintenance_records (
  maintenance_id      TEXT PRIMARY KEY,
  truck_id            TEXT NOT NULL,
  maintenance_type    TEXT,
  downtime_hours      REAL,
  odometer_reading    INTEGER,
  labor_hours		  REAL,
  labor_cost          REAL,
  parts_cost          REAL,
  total_cost          REAL,
  facility_location   TEXT,
  service_description TEXT,
  maintenance_date    TEXT,
  FOREIGN KEY (truck_id) REFERENCES trucks(truck_id)
);

CREATE TABLE safety_incidents (
  incident_id         TEXT PRIMARY KEY,
  trip_id             TEXT NOT NULL,
  truck_id            TEXT NOT NULL, --Only one row was null so it was treated as invalid data as you cannot have a safety incident without a truck
  driver_id           TEXT NOT NULL, --Only one row was null so it was treated as invalid data and will be deleted on load.
  incident_date       TEXT,
  incident_type       TEXT,
  description         TEXT,
  location_city       TEXT,
  location_state      TEXT,
  at_fault_flag       INTEGER,
  injury_flag         INTEGER, 
  preventable_flag    INTEGER, 
  cargo_damage_cost   REAL,
  claim_amount        REAL,
  vehicle_damage_cost REAL,
  FOREIGN KEY (trip_id)   REFERENCES trips(trip_id),
  FOREIGN KEY (truck_id)  REFERENCES trucks(truck_id),
  FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

--Aggregate Tables

CREATE TABLE driver_monthly_metrics (
  driver_id             TEXT NOT NULL,
  month                 TEXT NOT NULL,
  average_idle_hours    REAL,
  average_mpg           REAL,
  on_time_delivery_rate REAL,
  total_fuel_gallons    REAL,
  total_miles           INTEGER,
  total_revenue         REAL,
  trips_completed       INTEGER,
  PRIMARY KEY (driver_id, month),
  FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

CREATE TABLE truck_utilization_metrics (
  truck_id             TEXT NOT NULL,
  month                TEXT NOT NULL,
  average_mpg          REAL,
  downtime_hours       REAL,
  maintenance_cost     REAL,
  maintenance_events   INTEGER,
  total_miles          INTEGER,
  total_revenue        REAL,
  trips_completed      INTEGER,
  utilization_rate     REAL,
  PRIMARY KEY (truck_id, month),
  FOREIGN KEY (truck_id) REFERENCES trucks(truck_id)
);