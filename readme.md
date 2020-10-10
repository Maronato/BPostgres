# Postgres With Backups

Postgres 11 Database that auto backups every day at 3am.

To use it, create a volume that points to the database and one that points to the backups

Then, bind them to the container at `/var/lib/postgresql/data/pgdata` and `/backups`
```
docker network create --driver bridge postgres_net
docker volume create --name postgres_data
docker volume create --name postgres_backups
docker run \
  -v postgres_data:/var/lib/postgresql/data/pgdata \
  -v postgres_backups:/backups \
  --network postgres_net \
  -e POSTGRES_PASSWORD=mypassword \
  --name postgres_db \
  -d \
  maronato/bpostgres:11
```

Then connect to it remotely using the network and the name of the container/service as host:
```
docker run -it --rm --network postgres_net maronato/bpostgres:11 psql -h postgres_db -U postgres
```

# Manual backup
You can also run manual backups:
```
docker exec -it postgres_db /bin/bash -c "./backup.sh"
```

## Restoring
To restore, select a day (zero padded e.g 02), a month (full month name e.g. June), a year and the target database to restore.

The year is optional and will default to the current.
```
docker exec -it postgres_db /bin/bash -c " \
DAY=02 \
MONTH=June \
YEAR=2019 \
TARGET_DB=mydb \
./restore.sh"
```
