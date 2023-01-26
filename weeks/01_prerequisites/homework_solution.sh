#!/bin/bash
#

set -e
set -o pipefail

export $(grep -v '^#' ./.env | xargs)

echo "# Week 1: Homework"
echo ""
echo "## Question 1: Knowing docker tags"

docker build --help | grep 'Write the image ID to the file'

echo ""
echo "## Question 2"
echo ""
echo "### Understanding docker first run"
echo ""

docker pull python:3.9
count_packages=$({
  docker run \
    --name test-python \
    python:3.9 \
    pip list \
    --format=freeze \
    --disable-pip-version-check \
    | wc -l
})

docker rm test-python
echo "There are ${count_packages} installed packages!"

echo ""
echo "### Prepare Postgres"
echo ""

echo "Starting container"

docker volume create pg-nyc-vol
docker pull postgres:latest
docker run \
  --detach \
  --name pg-nyc \
  -p "${DB_PORT}:5432" \
  -e POSTGRES_PASSWORD="${DB_PASSWORD}" \
  -e POSTGRES_USER="${DB_USER}" \
  -e POSTGRES_DB="${DB_NAME}" \
  -v pg-nyc-vol:/var/lib/postgresql/data \
  postgres:latest



echo "Downloading Trip data..."
trip_file="green_tripdata_2019-01.csv"

wget -nc \
  -P data \
  "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/${trip_file}.gz"

[ ! -f "./data/${trip_file}" ] \
  && gzip -d --keep "data/${trip_file}.gz"

echo "Downloading zone data..."
zone_file="taxi+_zone_lookup.csv"

wget -nc \
  -P data \
  "https://s3.amazonaws.com/nyc-tlc/misc/${zone_file}"

echo "Inserting data into database..."

# waiting for the container to be up and ready :))
sleep 5

echo " - Setting up schema..."
psql service=nyc -f weeks/01_prerequisites/db_schema_01.sql
echo " - Inserting table taxi_zone..."
psql service=nyc -c "\copy taxi_zone FROM './data/${zone_file}' DELIMITER ',' CSV HEADER"
echo " - Inserting table taxi_trip..."
psql service=nyc -c "\copy taxi_trip FROM './data/${trip_file}' DELIMITER ',' CSV HEADER"

echo " - Database prepared :)"

echo ""
echo "Question 3"
echo "Count records"
echo ""

psql service=nyc <<SQL
SELECT Count(*)
FROM taxi_trip
WHERE pickup_at::DATE = '2019-01-15'
  AND dropoff_at::DATE = '2019-01-15';
SQL

echo ""
echo "## Question 4"
echo "Largist trip for each day"
echo ""

psql service=nyc <<SQL
SELECT pickup_at::DATE AS day, Max(trip_distance) AS max_dist
FROM taxi_trip
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
SQL

echo ""
echo "## Question 5"
echo "The number of passengers"
echo ""

psql service=nyc <<SQL
SELECT passenger_count, Count(*)
FROM taxi_trip
WHERE pickup_at::DATE = '2019-01-01' AND passenger_count IN (2, 3)
GROUP BY 1
ORDER BY 1;
SQL

echo ""
echo "## Question 6"
echo "Largest tip"
echo ""

psql service=nyc <<SQL
SELECT loc_pu.zone AS pu_zone, loc_do.zone AS do_zeon, tip_amount
FROM taxi_trip AS tt
JOIN taxi_zone AS loc_pu ON tt.pu_location_id = loc_pu.location_id
JOIN taxi_zone AS loc_do ON tt.do_location_id = loc_do.location_id
WHERE loc_pu.zone = 'Astoria'
ORDER BY 3 DESC
LIMIT 1;
SQL

