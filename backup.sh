#!/bin/bash

pgenv=/pgenv.sh
config_backup=/docker-entrypoint-initdb.d/config_backups.sh

# If /pgenv.sh does not exist, run config_backup again
if [ ! -f $pgenv ]
then
      source $config_backup
fi

source $pgenv

#echo "Running with these environment options" >> /var/log/cron.log
#set | grep PG >> /var/log/cron.log

NOW=$(date '+%d/%m/%Y %H:%M:%S');
DATE=`date +%d-%B-%Y`
MONTH=$(date +%B)
YEAR=$(date +%Y)
BASEDIR=/backups
BACKUPDIR=${BASEDIR}/${YEAR}/${MONTH}
mkdir -p ${BACKUPDIR}
cd ${BACKUPDIR}

echo "$NOW Backup running to $BACKUPDIR" >> /var/log/cron.log

#
# Loop through each pg database backing it up
#
DBLIST=`psql -l | awk '$1 !~ /[+(|:]|Name|List|template|postgres/ {print $1}'`
# echo "Databases to backup: ${DBLIST}" >> /var/log/cron.log
for DB in ${DBLIST}
do
  echo "$NOW Backing up $DB" >> /var/log/cron.log
  if [ -z "${ARCHIVE_FILENAME:-}" ]; then
        FILENAME=${BACKUPDIR}/${DUMPPREFIX}_${DB}.${DATE}.dmp
  else
        FILENAME="${ARCHIVE_FILENAME}.${DB}.dmp"
  fi
  if [[ -f ${BASEDIR}/globals.sql ]]; then
        rm ${BASEDIR}/globals.sql
        pg_dumpall -U ${PGUSER} --globals-only -f ${BASEDIR}/globals.sql
  else
        echo "$NOW Dump users and permisions" >> /var/log/cron.log
        pg_dumpall -U ${PGUSER} --globals-only -f ${BASEDIR}/globals.sql
  fi
  pg_dump -U ${PGUSER} -Fc -f ${FILENAME} ${DB}
done
