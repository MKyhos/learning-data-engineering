BEGIN;
DROP TABLE IF EXISTS taxi_zone;
CREATE TABLE taxi_zone (
  location_id int PRIMARY KEY,
  borough text,
  zone text,
  service_zone text
);

DROP TABLE IF EXISTS taxi_trip;
CREATE TABLE taxi_trip (
  vendor_id INT,
  pickup_at TIMESTAMP WITHOUT TIME ZONE,
  dropoff_at TIMESTAMP WITHOUT TIME ZONE,
  store_fwd_flag TEXT,
  ratecode_id INT,
  pu_location_id INT,
  do_location_id INT,
  passenger_count INT,
  trip_distance NUMERIC,
  fare_amount MONEY,
  extra MONEY,
  mta_tax MONEY,
  tip_amount MONEY,
  tolls_amount MONEY,
  ehail_fee MONEY,
  improvement_surcharge MONEY,
  total_amount MONEY,
  payment_type INT,
  trip_type INT,
  congestion_surcharge MONEY
);

COMMIT;