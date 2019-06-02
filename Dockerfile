# Use a Postgres version with PostGIS
FROM mdillon/postgis:11-alpine

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
ADD start.sh /start.sh
# Start crontab
RUN /usr/bin/crontab /crontab.txt

# Base command starts the cronjob in the foreground and then starts postgres
CMD ["/start.sh"]
