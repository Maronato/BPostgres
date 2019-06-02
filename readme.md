# Postgres With Backups

Postgres Database (+PostGIS) that auto backups every day.

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

Them connect to it:
```
docker run -it --rm --network postgres_net maronato/bpostgres:11 psql -h postgres_db -U postgres
```
