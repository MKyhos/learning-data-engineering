FROM  alpine:latest

RUN apk add --no-cache wget postgresql-client gzip bash

WORKDIR /opts
ENV PGPASSFILE="/opts/passfile" \
    PGSERVICEFILE="/opts/servicefile"

RUN mkdir -p data

COPY populate_data.sh /opts/populate_data.sh
COPY create_pg_files.sh /opts/create_pg_files.sh

CMD bash create_pg_files.sh && bash populate_data.sh

