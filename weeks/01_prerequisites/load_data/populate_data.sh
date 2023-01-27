#!/bin/bash

set -e
set -o pipefail

source ./create_pg_files.sh


[ ! -f $PGPASSFILE ] \
  && echo "PGPASSFILE not found, aborting" \
  && exit 1

[ ! -f $PGSERVICEFILE ] \
  && echo "PGSERVICEFILE not found, aborting" \
  && exit 1

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
echo " - Inserting table taxi_zone..."
psql service=nyc -c "\copy taxi_zone FROM './data/${zone_file}' DELIMITER ',' CSV HEADER"
echo " - Inserting table taxi_trip..."
psql service=nyc -c "\copy taxi_trip FROM './data/${trip_file}' DELIMITER ',' CSV HEADER"

echo " - Database prepared :)"




