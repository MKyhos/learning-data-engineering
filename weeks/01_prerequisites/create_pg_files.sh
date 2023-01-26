#!/bin/bash

set -e
set -o pipefail
export $(grep -v '^#' .env | xargs)


echo "Creating PG Secret Files"
echo " - populating service file"

printf "[%s]\nhost=%s\nport=%s\nuser=%s\ndbname=%s" \
  $DB_SERVICE_NAME $DB_HOST $DB_PORT $DB_USER $DB_NAME \
  > ./.pg_service.conf 

echo " - populating passfile"

echo "${DB_HOST}:${DB_PORT}:${DB_USER}:${DB_PASSWORD}" > ./.pgpass
chmod 0600 ./.pgpass

echo "Done."