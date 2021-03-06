#!/bin/bash

set -e

prefix=/etc/raddb

wait_for_certs() {
    printf "Waiting for cert $1 to be generated"
    until docker exec ${certgenerator_id} ls $prefix/certs/$1 &> /dev/null
    do
        printf "."
        sleep 1
    done
    printf "\n"
}

docker-compose stop certgenerator
docker-compose up --build -d certgenerator
certgenerator_id=$(docker ps -aqf "name=certgenerator")
wait_for_certs server.pem
wait_for_certs client.pem
wait_for_certs ca.pem
docker cp ${certgenerator_id}:$prefix/certs/ ./test
cat ./test/certs/server.key >> ./test/certs/server.pem
cat ./test/certs/ca.key >> ./test/certs/ca.pem
cat ./test/certs/client.key >> ./test/certs/client.pem
mkdir -p ./test/certs/radsec
cp -pr ./test/certs/server.pem ./test/certs/ca.pem ./test/certs/radsec/