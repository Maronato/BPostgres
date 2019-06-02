#!/bin/bash

source /pgenv.sh

DAY=${DAY}
MONTH=${MONTH}
YEAR=${YEAR:=$(date +%Y)}
TARGET_DB=${TARGET_DB}

if [ -z "$DAY" ]; then
        echo "DAY needed."
        exit 1
fi
if [ -z "$MONTH" ]; then
        echo "MONTH needed."
        exit 1
fi

if [ -z "$TARGET_DB" ]; then
        echo "TARGET_DB needed."
        exit 1
fi

DATE=$DAY-$MONTH-$YEAR

BASEDIR=/backups
BACKUPDIR=${BASEDIR}/${YEAR}/${MONTH}
FILENAME=${BACKUPDIR}/${DUMPPREFIX}_${TARGET_DB}.${DATE}.dmp

[ -f $FILENAME ] || (echo "$FILENAME does not exist" && exit 1)

echo "You are about to restore the following DB:"
echo "TARGET_DB: ${TARGET_DB}"
echo "DAY: ${DAY}"
echo "MONTH: ${MONTH}"
echo "YEAR: ${YEAR}"
read -r -p "Are you sure? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]
then
    echo "Dropping target DB"
    psql -U ${PGUSER} -c "DROP DATABASE ${TARGET_DB};"
    echo "Recreating DB"
    psql -U ${PGUSER} -c "CREATE DATABASE ${TARGET_DB};"

    echo "Restoring dump file"
    psql -U ${PGUSER} ${TARGET_DB} < /backups/globals.sql
    pg_restore -U ${PGUSER} ${FILENAME} | psql -d ${TARGET_DB}
fi
