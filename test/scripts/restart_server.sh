#!/bin/bash

set -e

prefix=/etc/freeradius/3.0

server_id=$(docker ps -aqf "name=network-access-control-integration-tests_server")
docker container restart ${server_id}
