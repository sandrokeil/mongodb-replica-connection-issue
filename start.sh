#!/usr/bin/env bash

GREEN=`tput setaf 2`
RESET=`tput sgr0`

query() {
    date
    echo "${GREEN}Querying${RESET}"
    wget -qO - http://localhost:8080 & wget -qO - http://localhost:8080
}

sleeping() {
    date
    IDLE_TIME=$1
    until [ $IDLE_TIME -lt 1 ]; do
        let IDLE_TIME-=1
        printf "${IDLE_TIME} "
        sleep 1
    done
    echo ""
}

rebuildMongoNode() {
    date
    query

    echo "${GREEN}Remove node $1 ${RESET}"
    docker-compose stop mongodb$1 && docker-compose rm  -f mongodb$1
    sleeping 60

    docker-compose exec mongodb$2 sh status.sh

    query

    echo "${GREEN}Add node $1 ${RESET}"
    docker-compose up -d mongodb$1
    sleeping 60

    docker-compose exec mongodb$2 sh status.sh

    query
}

docker-compose up -d --no-recreate

docker-compose ps

echo "${GREEN}Initialize cluster in T-5s${RESET}"
sleeping 5
docker-compose exec mongodb0 sh init.sh

echo "${GREEN}Test starts in T-20s${RESET}"
sleeping 20

docker-compose exec mongodb0 sh status.sh

echo "${GREEN}Testing ...${RESET}"
query

sleeping 5

rebuildMongoNode 2 1
rebuildMongoNode 1 0
rebuildMongoNode 0 2

date
echo "${GREEN}Cluster status by node 0${RESET}"
docker-compose exec mongodb0 sh status.sh
echo "${GREEN}Cluster status by node 1${RESET}"
docker-compose exec mongodb1 sh status.sh
echo "${GREEN}Cluster status by node 2${RESET}"
docker-compose exec mongodb2 sh status.sh

query
query
query

AFTER_IDLE_TIME=900

echo "${GREEN}Starting after test queries every 5s.${RESET}"

until [ $AFTER_IDLE_TIME -lt 1 ]; do
    date
    let AFTER_IDLE_TIME-=5
    printf "${AFTER_IDLE_TIME} "
    query
    sleep 5
done
