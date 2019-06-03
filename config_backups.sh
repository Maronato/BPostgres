#!/bin/bash

# Check if each var is declared and if not,
# set a sensible default

if [ -z "${POSTGRES_USER}" ]; then
  POSTGRES_USER=postgres
fi

if [ -z "${POSTGRES_PASS}" ]; then
  POSTGRES_PASS=docker
fi

if [ -z "${POSTGRES_PORT}" ]; then
  POSTGRES_PORT=5432
fi

if [ -z "${POSTGRES_HOST}" ]; then
  POSTGRES_HOST=localhost
fi

if [ -z "${POSTGRES_DBNAME}" ]; then
  POSTGRES_DBNAME=postgres
fi

if [ -z "${DUMPPREFIX}" ]; then
  DUMPPREFIX=PG
fi

# Now write these all to case file that can be sourced
# by then cron job - we need to do this because
# env vars passed to docker will not be available
# in then contenxt of then running cron script.

echo "
export PGUSER=$POSTGRES_USER
export PGPASSWORD=$POSTGRES_PASSWORD
export PGPORT=$POSTGRES_PORT
export PGHOST=$POSTGRES_HOST
export PGDATABASE=$POSTGRES_DBNAME
export DUMPPREFIX=$DUMPPREFIX
export ARCHIVE_FILENAME="${ARCHIVE_FILENAME}"
 " > /pgenv.sh

 ls

echo "Start script running with these environment options"
set | grep PG

echo "Starting cron in the background"
/usr/sbin/crond -l 8

