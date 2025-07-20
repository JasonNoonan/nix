set -eu

docker compose up -d
./templates/full.sh
docker compose stop
