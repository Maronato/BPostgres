# Use a Postgres version with PostGIS
FROM postgres:12-alpine

# Set default env
ENV PGDATA=/var/lib/postgresql/data/pgdata

# Install postgres client
RUN apk update;
RUN apk add postgresql-client
# Add crontab and logs
ADD crontab.txt /crontab.txt
RUN touch /var/log/cron.log
# Add backup restore and start scripts
ADD backup.sh /backup.sh
ADD restore.sh /restore.sh
RUN chmod a+x /backup.sh
RUN chmod a+x /restore.sh
# Set crontab
RUN /usr/bin/crontab /crontab.txt

# Base command starts the cronjob in the foreground and then starts postgres
COPY ./config_backups.sh /docker-entrypoint-initdb.d/config_backups.sh
