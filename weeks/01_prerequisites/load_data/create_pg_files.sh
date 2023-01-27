#!/bin/bash

set -e
set -o pipefail

for var in $DB_HOST $DB_NAME $DB_PASSWORD $DB_PORT $DB_USER; do
  [ -z "${var}" ] && echo "Env ${!var@} is not set!" && exit 1;
done;

echo "Creating PG Secret Files"
echo " - populating service file at '${PGSERVICEFILE}'"

printf "[%s]\nhost=%s\nport=%s\nuser=%s\ndbname=%s" \
  $DB_SERVICE_NAME $DB_HOST $DB_PORT $DB_USER $DB_NAME \
  > "${PGSERVICEFILE}"

echo " - populating passfile at '${PGPASSFILE}'"

echo "${DB_HOST}:${DB_PORT}:${DB_NAME}:${DB_USER}:${DB_PASSWORD}" > "${PGPASSFILE}"
chmod 0600 "${PGPASSFILE}"

echo "Done."
