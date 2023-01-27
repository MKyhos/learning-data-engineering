#!/bin/bash


docker network create nyc-net
docker volume create nyc-db-vol

docker run \
  -d \
  --env-file database/env.list \
  --network nyc-net \
  -v nyc-db-vol:/var/lib/postgresql/data \
  -p "5433:5432" \
  --name db \
  db:latest

sleep 5

docker run \
  --env-file load_data/env.list \
  --network nyc-net \
  --name data_loader \
  load_data:latest 
