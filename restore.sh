#!/bin/bash

source /pgenv.sh

echo "TARGET_DB: ${TARGET_DB}"
echo "TARGET_ARCHIVE: ${TARGET_ARCHIVE}"

if [ -z "${TARGET_ARCHIVE:-}" ] || [ ! -f "${TARGET_ARCHIVE:-}" ]; then
        echo "TARGET_ARCHIVE needed."
        exit 1
fi

if [ -z "${TARGET_DB:-}" ]; then
        echo "TARGET_DB needed."
        exit 1
fi

echo "Dropping target DB"
psql -U ${PGUSER} -c "DROP DATABASE ${TARGET_DB};"
echo "Recreating DB"
psql -U ${PGUSER} -c "CREATE DATABASE ${TARGET_DB};"

echo "Restoring dump file"
psql -U ${PGUSER} ${TARGET_DB} < /backups/globals.sql
pg_restore -U ${PGUSER} ${TARGET_ARCHIVE} | psql -d ${TARGET_DB}
