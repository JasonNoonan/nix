#! bash
set -eu

docker compose up -d
./templates/full.sh $1 $2
docker compose stop
